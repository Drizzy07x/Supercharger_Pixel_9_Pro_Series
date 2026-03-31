#!/system/bin/sh

# --- 1. HARDWARE GUARD ---
DEVICE=$(getprop ro.product.device)
MODEL=$(getprop ro.product.model)

ui_print "*********************************************************"
ui_print "  PIXEL 9 PRO SERIES SUPERCHARGER 🚀"
ui_print "  Build: v1.5.1 Stable | TCP & Perf Fix"
ui_print "*********************************************************"

if [ "$DEVICE" != "komodo" ] && [ "$DEVICE" != "caiman" ] && [ "$DEVICE" != "comet" ]; then
  ui_print " [❌] ERROR: INCOMPATIBLE DEVICE"
  abort " ! Aborting for system safety !"
fi

ui_print " [✅] TARGET HARDWARE VERIFIED: $MODEL"

ui_print " "
ui_print "  ____  _              _    __    "
ui_print " |  _ \(_)_  _____| |  / /_   "
ui_print " | |_) | \ \/ / _ \ | |  _ \  "
ui_print " |  __/| |>  <  __/ | | (_) | "
ui_print " |_|   |_/_/\_\___|_|  \___/  "
ui_print "  S U P E R C H A R G E R  v1.5.1"
ui_print " "

ui_print "========================================================="
ui_print " ✦ Injecting TCP 'Race to Sleep' Tweaks..."
sleep 0.2
ui_print " ✦ Applying CPU & 16GB Performance Fix..."
sleep 0.2
ui_print " ✦ Activating Dashboard v1.5.1..."
ui_print "========================================================="

# Permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
[ -d "$MODPATH/webroot" ] && set_perm_recursive $MODPATH/webroot 0 0 0755 0644
