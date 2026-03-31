# Pixel 9 Pro XL Supercharger 🚀
**The Elite Hardware Optimization Module for *komodo***

[![Version](https://img.shields.io/badge/Version-v1.5--Stable-blue?style=for-the-badge)](https://github.com/Drizzy07x/Pixel-9-Pro-XL-Supercharger)
[![Device](https://img.shields.io/badge/Device-Pixel%209%20Pro%20XL-orange?style=for-the-badge)](https://github.com/Drizzy07x/Pixel-9-Pro-XL-Supercharger)
[![Android](https://img.shields.io/badge/Android-16-green?style=for-the-badge)](https://github.com/Drizzy07x/Pixel-9-Pro-XL-Supercharger)

---

### **Introduction**
The **Pixel 9 Pro XL Supercharger** is a precision-tuned Magisk module built specifically for the ***komodo*** device. Unlike generic optimization scripts, this module is engineered to extract maximum performance from the **Tensor G4** processor, **16GB LPDDR5X RAM**, and ultra-fast **UFS 4.0 storage**.

Specifically designed and optimized for **Android 16** (tested on **Evolution X 11.6.2**), this module ensures a locked-in smooth experience while maintaining long-term hardware integrity.

---

### **💎 What's New in v1.5 Stable**
* **Advanced Hardware Diagnostic Engine**: Automatically generates a technical log at `/data/adb/modules/p9pxl_supercharger/debug.log`.
* **Thermal & RAM Monitoring**: Logs real-time SoC temperature and memory availability during the boot process to ensure peak performance.
* **Dynamic Visual Dashboard**: Real-time status indicators in the Magisk app (⏳ for initializing, ✅ for success, ❌ for error).
* **Automatic Updates**: Now supports Magisk's built-in update system via `update.json`.

---

### **⚡ Core Features**
* **Precision Memory Management**: Optimized Dalvik VM properties (`heapsize: 1GB`, `growthlimit: 512MB`) tailored for the **16GB RAM** capacity.
* **UFS 4.0 Storage Boost**: Enhanced I/O scheduling (using `none` scheduler) and 512KB read-ahead buffers for near-instant app loading and gaming.
* **Next-Gen UI Fluidity**: Forces the **Skia Vulkan (SkiaVK)** renderer and increases touch responsiveness for a consistent, locked 120Hz feel.
* **Hardware Efficiency**: Applies subtle `powersave_bias` to the Tensor G4 core clusters to prevent thermal throttling during intense multitasking.
* **Automated Maintenance**: Triggers an **SQLite VACUUM/REINDEX** and the **ART background compiler** (DexOpt) on every boot to keep the system database lean and fast.

---

### **🛠️ Installation**
1.  Download the latest **`Supercharger-v1.5-Stable.zip`** from the [Releases](https://github.com/Drizzy07x/Pixel-9-Pro-XL-Supercharger/releases) tab.
2.  Open the **Magisk** app and navigate to the **Modules** tab.
3.  Select **"Install from storage"** and choose the ZIP file.
4.  Reboot your device.
5.  **Important**: Wait **90 seconds** after reaching the home screen for the optimizations to trigger.

---

### **🔍 Verification & Support**
No terminal commands are required. To verify the module is working:
1.  **Check Magisk**: The module description will update to:  
    > `Status: [RUNNING] - System Optimized ✅ Efficiency Active`
2.  **Check Logs**: For a full technical breakdown, inspect:  
    `/data/adb/modules/p9pxl_supercharger/debug.log`

---

### **Disclaimer**
I am not responsible for bricked devices, hardware issues, or any other complications. Modifications are performed at your own risk.

**Developer**: [Drizzy_07](https://github.com/Drizzy07x)  
**Device**: Google Pixel 9 Pro XL (*komodo*)  
**Version**: 1.5 Stable

---

### **☕ Support the Project**
If the **Supercharger** has improved your experience, feel free to support the ongoing development!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow?style=for-the-badge&logo=buy-me-a-coffee)](https://www.buymeacoffee.com/Drizzy_07)
