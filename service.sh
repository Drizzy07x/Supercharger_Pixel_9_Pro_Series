#!/system/bin/sh
# =============================================================
# PIXEL 9 PRO XL SUPERCHARGER v1.5 [FINAL STABLE]
# Developed by: Drizzy_07
# Target Device: komodo (Google Pixel 9 Pro XL)
# Architecture: Tensor G4 | 16GB LPDDR5X | UFS 4.0
# Optimized for: Android 16 (Evolution X)
# =============================================================

# --- 1. PRE-BOOT INITIALIZATION ---
MOD_DIR="/data/adb/modules/p9pxl_supercharger"
PROP_FILE="$MOD_DIR/module.prop"
LOG_FILE="$MOD_DIR/debug.log"

# Set initial status in Magisk UI
sed -i "s/^description=.*/description=Status: [⏳] Supercharger is waiting for system boot.../" "$PROP_FILE"

# --- 2. DYNAMIC BOOT DETECTION ---
# Wait for Android 16 framework to be fully ready
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 10 # Grace period for SystemUI

# Update status: Starting Hardware Phase
sed -i "s/^description=.*/description=Status: [🧠] Optimizing 16GB RAM & [⚡] UFS 4.0.../" "$PROP_FILE"

# --- 3. LOGGING & DIAGNOSTICS ---
echo "===============================================" > "$LOG_FILE"
echo "   SUPERCHARGER v1.5 FINAL DIAGNOSTIC" >> "$LOG_FILE"
echo "   Developer: Drizzy_07 | Device: komodo" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"
echo "BOOT_TIME: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

# Log SoC Temperature and RAM status
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

# --- 4. CORE HARDWARE TUNING (RAM & I/O) ---
# Leveraging 16GB LPDDR5X
run_tweak "Dalvik GrowthLimit (512M)" "resetprop dalvik.vm.heapgrowthlimit 512m"
run_tweak "Dalvik HeapSize (1G)" "resetprop dalvik.vm.heapsize 1g"
run_tweak "VFS Cache Pressure (50)" "echo 50 > /proc/sys/vm/vfs_cache_pressure"

# UFS 4.0 Stability (128 requests to prevent screenshot errors)
for queue in /sys/block/sd*/queue; do
    echo none > "$queue/scheduler"
    echo 128 > "$queue/nr_requests"
    echo 512 > "$queue/read_ahead_kb"
done

# Update status: Connectivity Phase
sed -i "s/^description=.*/description=Status: [🌐] Tuning 5G/Wi-Fi & [🎮] UI Fluidity.../" "$PROP_FILE"

# --- 5. NETWORK, THERMAL & UI ---
# Race to Sleep Networking
run_tweak "TCP Fast Open (3)" "echo 3 > /proc/sys/net/ipv4/tcp_fastopen"
run_tweak "TCP Low Latency (1)" "echo 1 > /proc/sys/net/ipv4/tcp_low_latency"

# Tensor G4 Thermal Management
run_tweak "CPU Powersave Bias" "echo 1 > /sys/devices/system/cpu/cpufreq/policy0/powersave_bias"
run_tweak "ART Threads (4)" "resetprop dalvik.vm.dex2oat-threads 4"

# Graphics & Touch
run_tweak "Renderer SkiaVK" "resetprop debug.hwui.renderer skiavk"
run_tweak "Touch Latency" "resetprop persist.sys.touch.latency 0"

# --- 6. FINAL DASHBOARD DEPLOYMENT ---
# Capture final temp for the dashboard
CUR_TEMP_RAW=$(cat /sys/class/power_supply/battery/temp)
CUR_TEMP="$((CUR_TEMP_RAW / 10)).$((CUR_TEMP_RAW % 10))°C"

# Professional multi-emoji status line
STATUS="Status: [🚀] v1.5 ACTIVE | 🧠 16GB | ⚡ UFS 4.0 | 🌐 5G+ | 🌡️ $CUR_TEMP | ✅ Stable"
sed -i "s/^description=.*/description=$STATUS/" "$PROP_FILE"

# --- 7. STABILIZED MAINTENANCE (ASYNC) ---
# 180s delay to prevent MediaProvider collisions
(
    sleep 180
    if command -v sqlite3 >/dev/null 2>&1; then
        # Exclude media databases to ensure screenshot availability
        find /data/data -name "*.db" -type f -not -path "*com.android.providers.media*" 2>/dev/null | while read -r db; do
            sqlite3 "$db" "VACUUM; REINDEX;" >/dev/null 2>&1
        done
        echo "[🛠️] Maintenance: SQLite optimization completed ✅" >> "$LOG_FILE"
    fi
    cmd package bg-dexopt-job
    echo "[🛠️] Maintenance: ART Job Completed" >> "$LOG_FILE"
) &

echo "===============================================" >> "$LOG_FILE"
echo "   DEPLOYMENT COMPLETE - ENJOY THE SPEED 🚀" >> "$LOG_FILE"
exit 0
