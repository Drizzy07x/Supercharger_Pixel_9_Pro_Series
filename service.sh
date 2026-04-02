#!/system/bin/sh
# =============================================================
# PIXEL 9 PRO SERIES SUPERCHARGER v1.6-BETA
# Smart IRQ & BBR Networking Engine - Developed by: Drizzy_07
# =============================================================

MODDIR=${0%/*}
PROP_FILE="$MODDIR/module.prop"
LOG_FILE="$MODDIR/debug.log"

DEVICE=$(getprop ro.product.device)
MODEL=$(getprop ro.product.model)

# --- 1. LOG INITIALIZATION & PERMISSION ENFORCEMENT (From v1.5.1) ---
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 0666 "$LOG_FILE"
fi

echo "SUPERCHARGER DIAGNOSTIC LOG" > "$LOG_FILE"
echo "Build: v1.6-BETA (Experimental)" >> "$LOG_FILE"
echo "Device: $MODEL ($DEVICE)" >> "$LOG_FILE"
echo "Path: $MODDIR" >> "$LOG_FILE"
echo "-----------------------------------------------" >> "$LOG_FILE"

# --- 2. BOOT DETECTION ---
sed -i "s/^description=.*/description=Status: [⏳] Supercharger is waiting for system boot.../" "$PROP_FILE"
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 10
echo "[✅] System boot confirmed at $(date)" >> "$LOG_FILE"

# --- 3. PERFORMANCE TUNING (16GB RAM & UFS 4.0 from v1.5.1) ---
sed -i "s/^description=.*/description=Status: [🧠] RAM & [⚡] Storage.../" "$PROP_FILE"

resetprop dalvik.vm.heapstartsize 32m
resetprop dalvik.vm.heapgrowthlimit 512m
resetprop dalvik.vm.heapsize 1g
echo 60 > /proc/sys/vm/vfs_cache_pressure
echo 20 > /proc/sys/vm/dirty_ratio
echo 30 > /proc/sys/vm/swappiness
echo "[🧠] RAM: 16GB LPDDR5X Elite profile applied" >> "$LOG_FILE"

for queue in /sys/block/sd*/queue; do
    echo none > "$queue/scheduler"
    echo 256 > "$queue/nr_requests"
    echo 1024 > "$queue/read_ahead_kb"
done
echo "[⚡] Storage: UFS 4.0 high-throughput unlocked" >> "$LOG_FILE"

# --- 4. ADVANCED NETWORKING & CPU/GPU FLUIDITY ---
sed -i "s/^description=.*/description=Status: [🌐] Tuning BBR & [🎮] Smart IRQ.../" "$PROP_FILE"

# Advanced BBR + v1.5.1 TCP Tweaks
echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control
echo "fq" > /proc/sys/net/core/default_qdisc
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
echo 1 > /proc/sys/net/ipv4/tcp_low_latency
echo "[🌐] Network: TCP BBR, Fast Open, and Low Latency active" >> "$LOG_FILE"

# CPU Hang Prevention (From v1.5.1)
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/powersave_bias
echo 0 > /sys/devices/system/cpu/cpufreq/policy4/powersave_bias
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/powersave_bias
echo "[🔥] CPU: Performance clusters un-gated" >> "$LOG_FILE"

# Graphics & Touch (Restored from v1.5.1)
resetprop debug.hwui.renderer skiavk
resetprop persist.sys.touch.latency 0
resetprop persist.sys.ui.hw 1
echo "[🎮] UI: SkiaVK renderer and low latency touch applied" >> "$LOG_FILE"

# --- 5. SMART IRQ BALANCING (Efficiency + Power) ---
stop irqbalance
echo "[🚧] IRQ: Stock balancer disabled. Taking manual control." >> "$LOG_FILE"

# Isolate Prime Core (Mask 7f: Cores 0-6)
for irq in /proc/irq/*; do
    if [ -f "$irq/smp_affinity" ]; then
        echo "7f" > "$irq/smp_affinity" 2>/dev/null
    fi
done

# Map heavy I/O to Mid-Cores (Mask 70: Cores 4-6)
for irq in /proc/irq/*; do
    if grep -q -E "ufshc|pcie|modem|wlan" "$irq/name" 2>/dev/null; then
        echo "70" > "$irq/smp_affinity" 2>/dev/null
    fi
done
echo "[⚡] IRQ: UFS & Network mapped to Mid-Cores (Race to Idle)" >> "$LOG_FILE"

# Map Touchscreen to Performance Cores (Mask f0: Cores 4-7)
for irq in /proc/irq/*; do
    if grep -q -E "touch|goodix|sec_ts" "$irq/name" 2>/dev/null; then
        echo "f0" > "$irq/smp_affinity" 2>/dev/null
    fi
done
echo "[🎮] IRQ: Touch panel mapped for zero-latency response" >> "$LOG_FILE"

# --- 6. DYNAMIC DASHBOARD ENGINE ---
update_dashboard() {
    T_RAW=$(cat /sys/class/power_supply/battery/temp)
    T_UI="$((T_RAW / 10)).$((T_RAW % 10))°C"
    STATUS="Status: [🚀] v1.6-BETA | 🧠 IRQ-Smart | 🌐 BBR | 🌡️ Temp: $T_UI"
    sed -i "s/^description=.*/description=$STATUS/" "$PROP_FILE"
}

(
    while true; do
        update_dashboard
        sleep 60
    done
) &

# --- 7. ASYNC MAINTENANCE (From v1.5.1) ---
(
    sleep 180
    if command -v sqlite3 >/dev/null 2>&1; then
        find /data/data -name "*.db" -type f -not -path "*com.android.providers.media*" 2>/dev/null | while read -r db; do
            sqlite3 "$db" "VACUUM; REINDEX;" >/dev/null 2>&1
        done
    fi
    cmd package bg-dexopt-job
) &

echo "[🚀] Supercharger v1.6-BETA engine fully deployed" >> "$LOG_FILE"
exit 0
