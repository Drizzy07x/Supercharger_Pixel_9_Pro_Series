#!/system/bin/sh
# =============================================================
# PIXEL 9 PRO XL SUPERCHARGER v1.5 [STABLE]
# Developed by: Drizzy_07
# Target Device: komodo (Google Pixel 9 Pro XL)
# Architecture: Tensor G4 | 16GB LPDDR5X | UFS 4.0
# Optimized for: Android 16 (Evolution X)
# =============================================================

# --- 0. DYNAMIC BOOT DETECTION ---
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 10

# --- 1. INITIALIZATION & LOGGING ENGINE ---
MOD_DIR="/data/adb/modules/p9pxl_supercharger"
LOG_FILE="$MOD_DIR/debug.log"
PROP_FILE="$MOD_DIR/module.prop"

echo "===============================================" > "$LOG_FILE"
echo "   SUPERCHARGER v1.5 HARDWARE DIAGNOSTIC" >> "$LOG_FILE"
echo "   Developer: Drizzy_07 | Device: komodo" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"

# Hardware Metrics
TEMP_RAW=$(cat /sys/class/power_supply/battery/temp)
echo "🌡️ SOC_TEMP: $((TEMP_RAW / 10)).$((TEMP_RAW % 10))°C" >> "$LOG_FILE"
echo "💾 INITIAL_RAM_STATUS:" >> "$LOG_FILE"
free -m >> "$LOG_FILE"

run_tweak() {
    $2 2>>"$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[✅] SUCCESS: $1" >> "$LOG_FILE"
    else
        echo "[❌] FAILED: $1 | Error Code: $?" >> "$LOG_FILE"
    fi
}

# --- 2. KERNEL & NETWORK EFFICIENCY (New) ---
# Race to Sleep: Reduce modem active time
run_tweak "TCP Fast Open" "echo 3 > /proc/sys/net/ipv4/tcp_fastopen"
run_tweak "TCP Low Latency" "echo 1 > /proc/sys/net/ipv4/tcp_low_latency"

# VFS Management: Use 16GB RAM to avoid UFS 4.0 read cycles
run_tweak "VFS Cache Pressure (50)" "echo 50 > /proc/sys/vm/vfs_cache_pressure"
run_tweak "Dirty Ratio (10)" "echo 10 > /proc/sys/vm/dirty_ratio"

# --- 3. MEMORY & DALVIK (16GB RAM TUNING) ---
run_tweak "Dalvik GrowthLimit (512M)" "resetprop dalvik.vm.heapgrowthlimit 512m"
run_tweak "Dalvik HeapSize (1G)" "resetprop dalvik.vm.heapsize 1g"
run_tweak "Swappiness (60)" "echo 60 > /proc/sys/vm/swappiness"

# --- 4. THERMAL & POWER MANAGEMENT ---
run_tweak "CPU Powersave Bias" "echo 1 > /sys/devices/system/cpu/cpufreq/policy0/powersave_bias"
run_tweak "ART Threads (4)" "resetprop dalvik.vm.dex2oat-threads 4"

# --- 5. UI FLUIDITY & GRAPHICS ---
run_tweak "Renderer SkiaVK" "resetprop debug.hwui.renderer skiavk"
run_tweak "Touch Responsiveness" "settings put system touch_responsiveness 1"

# --- 6. STORAGE I/O (UFS 4.0 OPTIMIZATION) ---
for queue in /sys/block/sd*/queue; do
    echo "none" > "$queue/scheduler"
    echo "512" > "$queue/read_ahead_kb"
    echo "256" > "$queue/nr_requests"
    echo "0" > "$queue/iostats"
done

# --- 7. SYSTEM CLEANUP ---
settings put global wifi_scan_interval_ms 300000
run_tweak "Disable Statsd" "resetprop ro.statsd.enable false"
run_tweak "Disable Live Logcat" "resetprop logcat.live disable"

# --- 8. AUTOMATED MAINTENANCE ---
(
    if command -v sqlite3 >/dev/null 2>&1; then
        find /data/data -name "*.db" -type f 2>/dev/null | while read -r db; do
            sqlite3 "$db" "VACUUM; REINDEX;" >/dev/null 2>&1
        done
        echo "[🛠️] Maintenance: SQLite optimization completed ✅" >> "$LOG_FILE"
    fi
    cmd package bg-dexopt-job
    echo "[🛠️] Maintenance: ART Job Completed" >> "$LOG_FILE"
) &

# --- 9. DYNAMIC MAGISK DASHBOARD ---
STATUS="Status: [RUNNING] - System Optimized ✅ Efficiency Active"
sed -i "s/^description=.*/description=$STATUS/" "$PROP_FILE"

echo "===============================================" >> "$LOG_FILE"
echo "   DEPLOYMENT COMPLETE - ENJOY THE SPEED" >> "$LOG_FILE"
exit 0
