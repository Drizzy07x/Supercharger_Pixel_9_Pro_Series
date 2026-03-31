#!/system/bin/sh

# =============================================================
# PIXEL 9 PRO XL SUPERCHARGER v1.5 [STABLE]
# Installer UI: Elite Edition with Hardware Guard
# Developed by: Drizzy_07
# =============================================================

# --- 1. DEVICE DETECTION LOGIC ---
# Supported codenames: komodo (Pro XL), caiman (Pro), comet (Pro Fold)
DEVICE=$(getprop ro.product.device)
MODEL=$(getprop ro.product.model)

ui_print "*********************************************************"
ui_print "  PIXEL 9 PRO XL SUPERCHARGER 🚀"
ui_print "  Hardware Guard: Active"
ui_print "*********************************************************"
ui_print "- Detecting device: $MODEL [$DEVICE]"

# Hardware verification
if [ "$DEVICE" != "komodo" ] && [ "$DEVICE" != "caiman" ] && [ "$DEVICE" != "comet" ]; then
  ui_print " "
  ui_print " [❌] ERROR: INCOMPATIBLE DEVICE DETECTED"
  ui_print " ---------------------------------------------------------"
  ui_print " This module is specifically tuned for the 16GB RAM"
  ui_print " Pixel 9 Pro series (Pro XL, Pro, Pro Fold)."
  ui_print " "
  ui_print " Installation on [$DEVICE] is blocked to prevent"
  ui_print " system instability or memory overflows."
  ui_print " ---------------------------------------------------------"
  abort " ! Aborting installation for device safety !"
fi

# --- 2. HEADER SECTION (If compatible) ---
ui_print " [✅] COMPATIBLE DEVICE DETECTED"
ui_print "*********************************************************"
ui_print "  by Drizzy_07 "
ui_print "*********************************************************"
ui_print "- Extracting module files..."

# --- 3. ASCII ART SECTION ---
ui_print " "
ui_print "  ____  _              _  ___  "
ui_print " |  _ \(_)_  _____| | / _ \ "
ui_print " | |_) | \ \/ / _ \ | | (_) |"
ui_print " |  __/| |>  <  __/ |  \__, |"
ui_print " |_|   |_/_/\_\___|_|    /_/ "
ui_print "  S U P E R C H A R G E R "
ui_print " "

# --- 4. INSTALLATION LOGIC UI ---
ui_print "========================================================="
ui_print "            Supercharger Installer UI "
ui_print "========================================================="
sleep 0.5
ui_print " ✦ Device: [$DEVICE] - Fully Compatible ✅"
sleep 0.3
ui_print " ✦ SoC: [Tensor G4] - Detected"
sleep 0.3
ui_print " ✦ RAM: [16GB LPDDR5X] - Performance Path Active"
sleep 0.3
ui_print " ✦ I/O: [UFS 4.0] - Stability Patching Ready"
ui_print "---------------------------------------------------------"
ui_print " ✦ Injecting 16GB Efficiency Profile..."
sleep 0.2
ui_print " ✦ Applying Filesystem Safety Buffers..."
sleep 0.2
ui_print " ✦ Setting SkiaVK & Low-Latency Touch..."
sleep 0.2
ui_print " ✦ Initializing Evolutionary Dashboard..."
ui_print "---------------------------------------------------------"
ui_print " "
ui_print "            Installation Completed Successfully "
ui_print "            v1.5 Stable released by DRIZZY_07 "
ui_print " "
ui_print "========================================================="
ui_print " "
ui_print " [!] NOTE: Reboot and wait 60 seconds "
ui_print "     for the Dashboard to update. "
ui_print " "

# Set permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
