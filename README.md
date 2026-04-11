# 🚀 Pixel 9 Pro Series Supercharger v2.4 STABLE

[![Device](https://img.shields.io/badge/Device-Pixel_9_Pro_Series-blue?logo=google&logoColor=white)](https://github.com/Drizzy07x/Supercharger_Pixel_9_Pro_Series)
[![SoC](https://img.shields.io/badge/SoC-Tensor_G4-orange)](https://github.com/Drizzy07x/Supercharger_Pixel_9_Pro_Series)
[![Version](https://img.shields.io/badge/Version-v2.4_STABLE-green)](https://github.com/Drizzy07x/Supercharger_Pixel_9_Pro_Series/releases)
[![Android](https://img.shields.io/badge/Android-16_QPR3_&_17-brightgreen)](https://github.com/Drizzy07x/Supercharger_Pixel_9_Pro_Series)
[![Root](https://img.shields.io/badge/Root-Magisk_/_KernelSU-red)](https://github.com/Drizzy07x/Supercharger_Pixel_9_Pro_Series)

**Developed by:** [Drizzy07x](https://github.com/Drizzy07x)  
**Target devices:** Pixel 9 Pro XL (`komodo`), Pixel 9 Pro (`caiman`), Pixel 9 (`comet`)  
**Channel:** Stable  
**Compatibility:** Android 16 QPR3+, Android 17, Magisk, KernelSU  

---

## ✨ Overview

**Pixel 9 Pro Series Supercharger** is a systemless performance module built specifically for the **Pixel 9 series on Tensor G4**.

The goal of this project is not to stack random tweaks or chase flashy benchmark gains.  
The goal is to deliver a **cleaner, safer, and more consistent daily-use profile** that improves responsiveness while respecting battery life, thermal behavior, and boot safety.

`v2.4 STABLE` continues that direction by preserving the current tuning profile and improving **compatibility, diagnostics, and cross-version resilience**.

---

## 🎯 Project Goals

- Improve day-to-day smoothness and responsiveness
- Keep tuning selective and device-aware
- Avoid unnecessary aggressive behavior
- Preserve battery life and thermal consistency as much as possible
- Maintain clean boot behavior and predictable runtime behavior
- Improve logging, diagnostics, and long-term maintainability

---

## 📱 Supported Devices

This module is designed only for the **Pixel 9 series**:

- **Pixel 9 Pro XL** (`komodo`)
- **Pixel 9 Pro** (`caiman`)
- **Pixel 9** (`comet`)

Unsupported devices are not the target of this project.

---

## 🧠 What the Module Does

Supercharger focuses on a conservative and well-audited profile rather than extreme tuning.

### Current tuning direction
- Conservative **virtual memory tuning**
- Conditional `vm.page-cluster=0` when swap / zRAM is active
- Selective **IRQ affinity** for:
  - storage / UFS
  - Wi-Fi / network
  - touch / input
- Safe **block I/O tuning** on valid physical devices only
- Conservative **network tuning**
- Read-only verification for selected system properties
- Best-effort writes with graceful fallback on unsupported kernels

---

## 🛡️ Stability-First Design

This module is intentionally built around **safe application and clean fallback behavior**.

That means:
- no global IRQ affinity
- no forced CPU/GPU clocks
- no aggressive governor manipulation
- no uclamp experiments in the stable profile
- no blind writes to unsupported nodes
- no version hacks tied rigidly to a single Android build

The stable profile is designed to feel **better in real use**, not just look louder on paper.

---

## 🔍 Compatibility & Diagnostics

`v2.4 STABLE` improves compatibility across **Android 16 QPR3** and **Android 17** by relying on **real capability detection** instead of hardcoded version-specific logic.

### The module now validates things like:
- swap / zRAM availability
- battery temperature node availability
- `page-cluster` path support
- block scheduler availability
- scheduler option support
- supported congestion control options
- IRQ affinity target availability
- writable kernel paths before applying values

This makes the module more resilient across platform updates and kernel differences.

---

## 📊 Magisk Dashboard

The Magisk dashboard is designed to stay informative without becoming noisy.

### It does the following:
- waits for full Android boot
- shows module status and battery temperature
- updates temperature slowly and conditionally
- avoids unnecessary `module.prop` rewrites
- keeps presentation clean and readable

---

## ☕ Support the Project

If you like the project and want to support future development, testing, and refinement, you can help here:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow?style=for-the-badge&logo=buy-me-a-coffee)](https://www.buymeacoffee.com/Drizzy_07)

---

## 📝 Audit Log

All major actions are written to:

```sh
/data/adb/modules/p9pxl_supercharger/debug.log

