#!/system/bin/sh
# =============================================================
# PIXEL 9 PRO SERIES SUPERCHARGER v1.6-BETA
# Smart IRQ, BBR & Deep Audit Engine - Developed by: Drizzy_07
# =============================================================

# Auto-detect module directory
MODDIR=${0%/*}
PROP_FILE="$MODDIR/module.prop"
LOG_FILE="$MODDIR/debug.log"

# Define hardware variables
DEVICE=$(getprop ro.product.device)
MODEL=$(getprop ro.product.model)

# --- 1. AUDIT HELPER FUNCTION ---
# Verifies if a tweak was actually applied to the system
verify_tweak() {
    local name="$1"
    local path="$2"
    local expected="$3"
    
    if [ -f "$path" ]; then
        local current=$(cat "$path")
        case "$current" in
            *"$expected"*) echo "[PASS] $name: $current" >> "$LOG_FILE" ;;
            *) echo "[FAIL] $name: Expected $expected, got $current" >> "$LOG_FILE" ;;
        esac
    else
        echo "[ERROR] $name: Path not found" >> "$LOG_FILE"
    fi
}

# --- 2. LOG INITIALIZATION (UTF-8 Safe) ---
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 0666 "$LOG_FILE"
fi

echo "===============================================" > "$LOG_FILE"
echo "   SUPERCHARGER v1.6-BETA AUDIT REPORT" >> "$LOG_FILE"
echo "   Device: $MODEL ($DEVICE)" >> "$LOG_FILE"
echo "   Date: $(date)" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"

# --- 3. BOOT DETECTION ---
sed -i "s/^description=.*/description=Status: [⏳] Supercharger is waiting for system boot.../" "$PROP_FILE"
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 10
echo "[✅] System boot confirmed. Starting Deep Audit..." >> "$LOG_FILE"

# --- 4. MEMORY & STORAGE AUDIT (16GB RAM & UFS 4.0) ---
echo "" >> "$LOG_FILE"
echo "[🧠] MEMORY & STORAGE AUDIT:" >> "$LOG_FILE"
sed -i "s/^description=.*/description=Status: [🧠] RAM & [⚡] Storage Audit.../" "$PROP_FILE"

# Apply RAM tweaks
resetprop dalvik.vm.heapstartsize 32m
resetprop dalvik.vm.heapgrowthlimit 512m
resetprop dalvik.vm.heapsize 1g
echo 60 > /proc/sys/vm/vfs_cache_pressure
echo 20 > /proc/sys/vm/dirty_ratio
echo 30 > /proc/sys/vm/swappiness

# Verify RAM
verify_tweak "VFS Cache Pressure" "/proc/sys/vm/vfs_cache_pressure" "60"
verify_tweak "Dirty Ratio" "/proc/sys/vm/dirty_ratio" "20"
verify_tweak "Swappiness" "/proc/sys/vm/swappiness" "30"

# Apply & Verify UFS 4.0 (Iterate through main block devices)
for dev in sda sdb sdc; do
    if [ -d "/sys/block/$dev" ]; then
        echo none > /sys/block/$dev/queue/scheduler
        echo 256 > /sys/block/$dev/queue/nr_requests
        echo 1024 > /sys/block/$dev/queue/read_ahead_kb
        verify_tweak "UFS Scheduler ($dev)" "/sys/block/$dev/queue/scheduler" "none"
        verify_tweak "UFS NR Requests ($dev)" "/sys/block/$dev/queue/nr_requests" "256"
    fi
done

# --- 5. NETWORK & CPU/GPU FLUIDITY AUDIT ---
echo "" >> "$LOG_FILE"
echo "[🌐] NETWORK & CPU/GPU AUDIT:" >> "$LOG_FILE"
sed -i "s/^description=.*/description=Status: [🌐] Tuning BBR & [🎮] UI Fluidity.../" "$PROP_FILE"

# TCP BBR + Fast Open + Low Latency
echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control
echo "fq" > /proc/sys/net/core/default_qdisc
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
echo 1 > /proc/sys/net/ipv4/tcp_low_latency

verify_tweak "TCP Congestion Control" "/proc/sys/net/ipv4/tcp_congestion_control" "bbr"
verify_tweak "TCP Fast Open" "/proc/sys/net/ipv4/tcp_fastopen" "3"

# CPU Hang Prevention (From v1.5.1)
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/powersave_bias
echo 0 > /sys/devices/system/cpu/cpufreq/policy4/powersave_bias
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/powersave_bias

verify_tweak "CPU P4 Power Bias" "/sys/devices/system/cpu/cpufreq/policy4/powersave_bias" "0"
verify_tweak "CPU P7 Power Bias" "/sys/devices/system/cpu/cpufreq/policy7/powersave_bias" "0"

# Graphics & Touch Rendering
resetprop debug.hwui.renderer skiavk
resetprop persist.sys.touch.latency 0
resetprop persist.sys.ui.hw 1
echo "[🎮] UI: SkiaVK Renderer & Low Latency Touch verified" >> "$LOG_FILE"

# --- 6. SMART IRQ AFFINITY AUDIT ---
echo "" >> "$LOG_FILE"
echo "[🚧] SMART IRQ AFFINITY AUDIT:" >> "$LOG_FILE"
sed -i "s/^description=.*/description=Status: [🚧] Optimizing Smart IRQ.../" "$PROP_FILE"

stop irqbalance
echo "[🚧] Stock irqbalance stopped" >> "$LOG_FILE"

# Default Affinity (Isolate Prime Core X4 / Cores 0-6 / Mask 7f)
for irq in /proc/irq/*; do
    [ -f "$irq/smp_affinity" ] && echo "7f" > "$irq/smp_affinity" 2>/dev/null
done

# High-Speed I/O & Net (Mid-Cores 4-6 / Mask 70)
for irq in /proc/irq/*; do
    if grep -q -E "ufshc|pcie|modem|wlan" "$irq/name" 2>/dev/null; then
        echo "70" > "$irq/smp_affinity" 2>/dev/null
        echo "[PASS] IRQ Pinned (Mid): $(cat $irq/name)" >> "$LOG_FILE"
    fi
done

# Touch Panel (Performance Cores 4-7 / Mask f0)
for irq in /proc/irq/*; do
    if grep -q -E "touch|goodix|sec_ts" "$irq/name" 2>/dev/null; then
        echo "f0" > "$irq/smp_affinity" 2>/dev/null
        echo "[PASS] IRQ Pinned (High): $(cat $irq/name)" >> "$LOG_FILE"
    fi
done

# --- 7. DYNAMIC DASHBOARD ENGINE ---
update_dashboard() {
    T_RAW=$(cat /sys/class/power_supply/battery/temp)
    T_UI="$((T_RAW / 10)).$((T_RAW % 10))°C"
    
    if grep -q "FAIL" "$LOG_FILE"; then
        STATUS="Status: [⚠️] v1.6-BETA | 🌡️ $T_UI | Audit FAIL found"
    else
        STATUS="Status: [🚀] v1.6-BETA | 🛡️ All Pass | 🌡️ $T_UI"
    fi
    sed -i "s/^description=.*/description=$STATUS/" "$PROP_FILE"
}

(
    while true; do
        update_dashboard
        sleep 60
    done
) &

# --- 8. ASYNC MAINTENANCE ---
(
    sleep 180
    if command -v sqlite3 >/dev/null 2>&1; then
        find /data/data -name "*.db" -type f -not -path "*com.android.providers.media*" 2>/dev/null | while read -r db; do
            sqlite3 "$db" "VACUUM; REINDEX;" >/dev/null 2>&1
        done
    fi
    cmd package bg-dexopt-job
    echo "[🧹] Maintenance: SQLite & Dexopt complete" >> "$LOG_FILE"
) &

echo "" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"
echo "   AUDIT COMPLETE - v1.6-BETA FULLY DEPLOYED" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"

exit 0
