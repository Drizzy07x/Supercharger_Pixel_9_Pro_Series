#!/system/bin/sh

MODDIR=${0%/*}
PROP_FILE="$MODDIR/module.prop"
LOG_FILE="$MODDIR/debug.log"
DEVICE="$(getprop ro.product.device)"
MODEL="$(getprop ro.product.model)"

TEMP_UPDATE_INTERVAL=300
TEMP_DELTA_THRESHOLD=10

STORAGE_IRQ_PATTERNS="ufshcd|ufs"
NETWORK_IRQ_PATTERNS="wlan|wifi|wcnss|bcmdhd|dhd|rmnet|ipa"
TOUCH_IRQ_PATTERNS="synaptics|touch|goodix|fts|sec_touch|input"

log_line() {
    echo "$1" >> "$LOG_FILE"
}

safe_read() {
    [ -r "$1" ] && cat "$1" 2>/dev/null
}

safe_write_if_needed() {
    local path="$1"
    local value="$2"
    local label="$3"
    local current

    if [ ! -e "$path" ]; then
        log_line "[SKIP] $label: path not found ($path)"
        return 1
    fi

    if [ ! -w "$path" ]; then
        log_line "[SKIP] $label: path not writable"
        return 1
    fi

    current="$(safe_read "$path")"
    if [ "$current" = "$value" ]; then
        log_line "[PASS] $label: already set to $value"
        return 0
    fi

    if echo "$value" > "$path" 2>/dev/null; then
        current="$(safe_read "$path")"
        if [ "$current" = "$value" ]; then
            log_line "[PASS] $label: applied $value"
            return 0
        fi
        log_line "[FAIL] $label: write did not persist (current=${current:-<empty>})"
        return 1
    fi

    log_line "[FAIL] $label: write rejected"
    return 1
}

verify_prop() {
    local label="$1"
    local prop="$2"
    local expected="$3"
    local current

    current="$(getprop "$prop")"
    if [ "$current" = "$expected" ]; then
        log_line "[PASS] $label: $current"
    else
        log_line "[FAIL] $label: Expected $expected, got ${current:-<empty>}"
    fi
}

get_battery_temp_decic() {
    local raw

    if [ ! -r /sys/class/power_supply/battery/temp ]; then
        return 1
    fi

    raw="$(cat /sys/class/power_supply/battery/temp 2>/dev/null)"
    case "$raw" in
        ''|*[!0-9-]*)
            return 1
            ;;
        *)
            echo "$raw"
            return 0
            ;;
    esac
}

format_temp_label() {
    local decic="$1"
    local whole
    local frac

    if [ -z "$decic" ]; then
        echo "temp unavailable"
        return 0
    fi

    whole=$((decic / 10))
    frac=$((decic % 10))
    if [ "$frac" -lt 0 ]; then
        frac=$((frac * -1))
    fi
    echo "${whole}.${frac}C"
}

abs_diff_decic() {
    local a="$1"
    local b="$2"
    local diff

    diff=$((a - b))
    if [ "$diff" -lt 0 ]; then
        diff=$((diff * -1))
    fi
    echo "$diff"
}

get_dashboard_status() {
    local temp_decic="$1"
    local temp_ui

    temp_ui="$(format_temp_label "$temp_decic")"
    if grep -q "FAIL" "$LOG_FILE" 2>/dev/null; then
        echo "Status: [WARN] v2.3-BETA.1 | ${temp_ui} | Critical issue detected"
    else
        echo "Status: [OK] v2.3-BETA.1 | ${temp_ui} | All critical checks passed"
    fi
}

update_dashboard() {
    local force_log="$1"
    local temp_decic="$2"
    local status
    local current_line

    status="$(get_dashboard_status "$temp_decic")"
    current_line="$(grep '^description=' "$PROP_FILE" 2>/dev/null)"

    if [ "$current_line" = "description=$status" ]; then
        if [ "$force_log" = "1" ]; then
            log_line "[PASS] Dashboard: description already up to date"
        fi
        return 0
    fi

    if sed -i "s/^description=.*/description=$status/" "$PROP_FILE" 2>/dev/null; then
        log_line "[PASS] Dashboard: description updated"
        return 0
    fi

    log_line "[FAIL] Dashboard: unable to update module.prop"
    return 1
}

start_temp_dashboard_updater() {
    (
        local last_temp_decic
        local current_temp_decic
        local delta

        last_temp_decic="$1"

        while true; do
            sleep "$TEMP_UPDATE_INTERVAL"

            current_temp_decic="$(get_battery_temp_decic)"
            if [ -z "$current_temp_decic" ]; then
                continue
            fi

            if [ -n "$last_temp_decic" ]; then
                delta="$(abs_diff_decic "$current_temp_decic" "$last_temp_decic")"
                if [ "$delta" -lt "$TEMP_DELTA_THRESHOLD" ]; then
                    continue
                fi
            fi

            if update_dashboard "0" "$current_temp_decic"; then
                last_temp_decic="$current_temp_decic"
            fi
        done
    ) &
}

wait_for_full_boot() {
    local boot_wait=0

    log_line "[INFO] Waiting for full Android boot..."
    until [ "$(getprop sys.boot_completed)" = "1" ] || [ "$boot_wait" -ge 180 ]; do
        sleep 2
        boot_wait=$((boot_wait + 2))
    done

    if [ "$(getprop sys.boot_completed)" != "1" ]; then
        log_line "[FAIL] Boot detection timed out after ${boot_wait}s"
        return 1
    fi

    boot_wait=0
    until [ "$(getprop init.svc.bootanim)" = "stopped" ] || [ "$boot_wait" -ge 60 ]; do
        sleep 2
        boot_wait=$((boot_wait + 2))
    done

    if [ "$(getprop init.svc.bootanim)" = "stopped" ]; then
        log_line "[PASS] Boot animation finished"
    else
        log_line "[SKIP] Boot animation state unavailable; continuing"
    fi

    sleep 10
    log_line "[PASS] System ready: post-boot grace period complete"
    return 0
}

has_active_swap() {
    local line

    if [ ! -r /proc/swaps ]; then
        return 1
    fi

    while read -r line; do
        case "$line" in
            Filename*|'')
                continue
                ;;
            *)
                return 0
                ;;
        esac
    done < /proc/swaps

    return 1
}

get_active_scheduler() {
    local content="$1"
    echo "$content" | sed -n 's/.*\[\([^]]*\)\].*/\1/p'
}

set_scheduler_if_available() {
    local scheduler_path="$1"
    local desired="$2"
    local label="$3"
    local current
    local active

    if [ ! -e "$scheduler_path" ]; then
        log_line "[SKIP] $label: scheduler node missing"
        return 1
    fi

    if [ ! -w "$scheduler_path" ]; then
        log_line "[SKIP] $label: scheduler node not writable"
        return 1
    fi

    current="$(safe_read "$scheduler_path")"
    active="$(get_active_scheduler "$current")"

    if [ "$active" = "$desired" ]; then
        log_line "[PASS] $label: already set to $desired"
        return 0
    fi

    case "$current" in
        *"$desired"*)
            if echo "$desired" > "$scheduler_path" 2>/dev/null; then
                current="$(safe_read "$scheduler_path")"
                active="$(get_active_scheduler "$current")"
                if [ "$active" = "$desired" ]; then
                    log_line "[PASS] $label: applied $desired"
                    return 0
                fi
                log_line "[FAIL] $label: scheduler stayed on ${active:-unknown}"
                return 1
            fi
            log_line "[FAIL] $label: scheduler write rejected"
            return 1
            ;;
        *)
            log_line "[SKIP] $label: '$desired' scheduler not available"
            return 1
            ;;
    esac
}

is_relevant_block_device() {
    local base="$1"
    local dev_path="$2"

    case "$base" in
        dm-*|loop*|ram*|zram*|md*|sr*|fd*)
            return 1
            ;;
    esac

    [ -d "$dev_path/queue" ] || return 1
    [ -e "$dev_path/device" ] || return 1

    return 0
}

apply_vm_tuning() {
    log_line ""
    log_line "[INFO] VIRTUAL MEMORY AUDIT:"

    safe_write_if_needed "/proc/sys/vm/vfs_cache_pressure" "60" "VFS Cache Pressure"
    safe_write_if_needed "/proc/sys/vm/dirty_background_ratio" "5" "VM Dirty Background Ratio"
    safe_write_if_needed "/proc/sys/vm/dirty_ratio" "12" "VM Dirty Ratio"

    if has_active_swap; then
        safe_write_if_needed "/proc/sys/vm/swappiness" "30" "VM Swappiness"
    else
        log_line "[SKIP] VM Swappiness: no active swap or zram detected"
    fi
}

apply_page_cluster() {
    log_line ""
    log_line "[INFO] PAGE CLUSTER AUDIT:"

    if has_active_swap; then
        safe_write_if_needed "/proc/sys/vm/page-cluster" "0" "VM Page Cluster"
    else
        log_line "[SKIP] VM Page Cluster: no active swap or zram detected"
    fi
}

apply_block_tuning() {
    local dev
    local base
    local processed=0
    local skipped=0

    log_line ""
    log_line "[INFO] BLOCK I/O AUDIT:"

    for dev in /sys/block/*; do
        [ -d "$dev" ] || continue
        base="$(basename "$dev")"

        if ! is_relevant_block_device "$base" "$dev"; then
            skipped=$((skipped + 1))
            log_line "[SKIP] Block Device ($base): not a physical target for tuning"
            continue
        fi

        processed=$((processed + 1))
        log_line "[INFO] Block Device ($base): processing"
        set_scheduler_if_available "$dev/queue/scheduler" "none" "Block Scheduler ($base)"
        safe_write_if_needed "$dev/queue/read_ahead_kb" "256" "Block Read Ahead ($base)"

        if [ -e "$dev/queue/iostats" ]; then
            safe_write_if_needed "$dev/queue/iostats" "0" "Block IO Stats ($base)"
        else
            log_line "[SKIP] Block IO Stats ($base): node missing"
        fi
    done

    log_line "[PASS] Block Device Scan: processed $processed devices, skipped $skipped"
}

network_value_available() {
    local path="$1"
    local token="$2"
    local current

    current="$(safe_read "$path")"
    case "$current" in
        *"$token"*)
            return 0
            ;;
    esac
    return 1
}

apply_network_tuning() {
    local cc_available
    local current_cc

    log_line ""
    log_line "[INFO] NETWORK AUDIT:"

    safe_write_if_needed "/proc/sys/net/core/default_qdisc" "fq" "Network Qdisc"

    cc_available="/proc/sys/net/ipv4/tcp_available_congestion_control"
    if [ -e "$cc_available" ]; then
        if network_value_available "$cc_available" "cubic"; then
            safe_write_if_needed "/proc/sys/net/ipv4/tcp_congestion_control" "cubic" "TCP Congestion"
        else
            log_line "[SKIP] TCP Congestion: cubic not available"
        fi
    elif [ -e "/proc/sys/net/ipv4/tcp_congestion_control" ]; then
        current_cc="$(safe_read /proc/sys/net/ipv4/tcp_congestion_control)"
        if [ "$current_cc" = "cubic" ]; then
            log_line "[PASS] TCP Congestion: already set to cubic"
        else
            log_line "[SKIP] TCP Congestion: availability unknown on this kernel"
        fi
    else
        log_line "[SKIP] TCP Congestion: node missing"
    fi

    safe_write_if_needed "/proc/sys/net/ipv4/tcp_fastopen" "1" "TCP Fast Open"
}

set_irq_affinity_value() {
    local path="$1"
    local mask="$2"
    local label="$3"
    local current

    if [ ! -e "$path" ]; then
        log_line "[SKIP] $label: affinity node missing"
        return 2
    fi

    if [ ! -w "$path" ]; then
        log_line "[SKIP] $label: affinity node not writable"
        return 3
    fi

    current="$(safe_read "$path")"
    if [ "$current" = "$mask" ]; then
        log_line "[PASS] $label: already set to $mask"
        return 0
    fi

    if echo "$mask" > "$path" 2>/dev/null; then
        current="$(safe_read "$path")"
        if [ "$current" = "$mask" ]; then
            log_line "[PASS] $label: applied $mask"
            return 0
        fi
    fi

    log_line "[SKIP] $label: kernel rejected affinity change; leaving default routing"
    return 1
}

apply_irq_affinity() {
    local patterns="$1"
    local mask="$2"
    local label="$3"
    local found=0
    local applied=0
    local rejected=0
    local omitted=0
    local irq_num
    local rc

    for irq_num in $(grep -iE "$patterns" /proc/interrupts 2>/dev/null | awk -F: '{print $1}' | tr -d ' '); do
        found=$((found + 1))
        set_irq_affinity_value "/proc/irq/$irq_num/smp_affinity" "$mask" "$label IRQ $irq_num"
        rc=$?
        case "$rc" in
            0) applied=$((applied + 1)) ;;
            1) rejected=$((rejected + 1)) ;;
            *) omitted=$((omitted + 1)) ;;
        esac
    done

    if [ "$found" -eq 0 ]; then
        log_line "[SKIP] $label: no matching IRQs found"
    fi

    log_line "[PASS] $label Summary: found $found | applied $applied | rejected $rejected | omitted $omitted"
}

apply_selective_irq_affinity() {
    log_line ""
    log_line "[INFO] SELECTIVE IRQ AFFINITY AUDIT:"

    apply_irq_affinity "$STORAGE_IRQ_PATTERNS" "70" "Storage/UFS IRQ"
    apply_irq_affinity "$NETWORK_IRQ_PATTERNS" "70" "Wi-Fi/Network IRQ"
    apply_irq_affinity "$TOUCH_IRQ_PATTERNS" "f0" "Touch/Input IRQ"
}

[ -f "$LOG_FILE" ] || touch "$LOG_FILE"
chmod 0644 "$LOG_FILE" 2>/dev/null

echo "===============================================" > "$LOG_FILE"
echo "   SUPERCHARGER v2.3-BETA.1 DEEP AUDIT" >> "$LOG_FILE"
echo "   Device: $MODEL ($DEVICE)" >> "$LOG_FILE"
echo "   Date: $(date)" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"

if ! wait_for_full_boot; then
    log_line ""
    log_line "[INFO] DASHBOARD AUDIT:"
    update_dashboard "1" ""
    exit 0
fi

TEMP_DECIC="$(get_battery_temp_decic)"
if [ -n "$TEMP_DECIC" ]; then
    log_line "[PASS] Battery Temp: $(format_temp_label "$TEMP_DECIC")"
else
    log_line "[SKIP] Battery Temp: sensor unavailable or invalid"
fi

log_line ""
log_line "[INFO] SYSTEM AND RAM AUDIT:"
verify_prop "Dalvik Heap Start" "dalvik.vm.heapstartsize" "32m"
verify_prop "Dalvik Heap Growth" "dalvik.vm.heapgrowthlimit" "512m"
verify_prop "Dalvik Heap Size" "dalvik.vm.heapsize" "1024m"
verify_prop "Touch Latency" "persist.sys.touch.latency" "0"

apply_vm_tuning
apply_page_cluster
apply_block_tuning
apply_network_tuning
apply_selective_irq_affinity

echo "" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"
echo "   AUDIT COMPLETE - PROFILE ACTIVE" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"

log_line ""
log_line "[INFO] DASHBOARD AUDIT:"
sleep 10
update_dashboard "1" "$TEMP_DECIC"
start_temp_dashboard_updater "$TEMP_DECIC"

exit 0
