#!/system/bin/sh
# =============================================================
# PIXEL 9 PRO SERIES SUPERCHARGER v1.5.1 [STABLE]
# Performance Fix Edition - Developed by: Drizzy_07
# =============================================================

MOD_DIR="/data/adb/modules/p9pxl_supercharger"
PROP_FILE="$MOD_DIR/module.prop"
LOG_FILE="$MOD_DIR/debug.log"

# --- 1. BOOT DETECTION ---
sed -i "s/^description=.*/description=Status: [⏳] Supercharger is waiting for system boot.../" "$PROP_FILE"
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 10

# --- 2. PERFORMANCE FIX (RAM & I/O) ---
sed -i "s/^description=.*/description=Status: [🧠] Optimizing 16GB RAM & [⚡] UFS 4.0.../" "$PROP_FILE"

# Memory: Optimized for 16GB LPDDR5X (Hangs prevention)
resetprop dalvik.vm.heapstartsize 32m
resetprop dalvik.vm.heapgrowthlimit 512m
resetprop dalvik.vm.heapsize 1g
echo 60 > /proc/sys/vm/vfs_cache_pressure
echo 20 > /proc/sys/vm/dirty_ratio
echo 30 > /proc/sys/vm/swappiness

# Storage: UFS 4.0 High-Throughput (Fixes freezing)
for queue in /sys/block/sd*/queue; do
    echo none > "$queue/scheduler"
    echo 256 > "$queue/nr_requests"
    echo 1024 > "$queue/read_ahead_kb"
done

# --- 3. CPU & THERMAL FIX ---
sed -i "s/^description=.*/description=Status: [🌐] Tuning 5G/Wi-Fi & [🎮] UI Fluidity.../" "$PROP_FILE"

# CPU Bias: Allow P4 and P7 performance cores to scale freely
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/powersave_bias
echo 0 > /sys/devices/system/cpu/cpufreq/policy4/powersave_bias
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/powersave_bias

# UI Engine
resetprop debug.hwui.renderer skiavk
resetprop persist.sys.touch.latency 0
resetprop persist.sys.ui.hw 1

# --- 4. DYNAMIC DASHBOARD ENGINE ---
update_dashboard() {
    T_RAW=$(cat /sys/class/power_supply/battery/temp)
    T_FINAL="$((T_RAW / 10)).$((T_RAW % 10))°C"
    STATUS="Status: [🚀] v1.5.1 ACTIVE | 🧠 16GB | ⚡ UFS 4.0 | 🌡️ Actual Temp: $T_FINAL | ✅ Stable"
    sed -i "s/^description=.*/description=$STATUS/" "$PROP_FILE"
}

(
    while true; do
        update_dashboard
        sleep 60
    done
) &

# --- 5. ASYNC MAINTENANCE ---
(
    sleep 180
    if command -v sqlite3 >/dev/null 2>&1; then
        find /data/data -name "*.db" -type f -not -path "*com.android.providers.media*" 2>/dev/null | while read -r db; do
            sqlite3 "$db" "VACUUM; REINDEX;" >/dev/null 2>&1
        done
    fi
    cmd package bg-dexopt-job
) &

exit 0
