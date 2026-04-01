# Changelog

All notable changes to the **Pixel 9 Pro Series Supercharger** will be documented in this file.

## [1.5.1 Stable] - 2026-03-31
### **Fixed**
* **Performance Regression**: Disabled `powersave_bias` on high-performance CPU clusters (P4/P7) to fix system hangs and freezes.
* **I/O Bottleneck**: Increased `nr_requests` to 256 and `read_ahead_kb` to 1024 for smoother UFS 4.0 data throughput.
* **Memory Management**: Adjusted `dirty_ratio` and `swappiness` to better utilize the 16GB LPDDR5X stack.
* **Encoding Fix**: Optimized `debug.log` output to prevent character encoding issues in text editors.

## [1.5 Stable] - 2026-03-31
### **Added**
* **Dynamic Dashboard**: Real-time status updates in Magisk/KSU description.
* **Live Temp Monitoring**: 60s SoC temperature refresh loop.
* **TCP Race to Sleep**: Fast Open and Low Latency network tweaks.

## [1.4 Stable] - 2026-03-30
* Initial release for Pixel 9 Pro XL.
* Basic Dalvik and I/O optimizations.
  
