# Patch Pre-Check CI Tool

This tool automates distribution detection, configuration, patch application, and kernel build/test workflows across supported Linux distributions.

---

## ✨ Features
- Automatic detection of target distribution
- Distro-specific build scripts.
- Patch management and pre-check CI integration
- Unified interface via `make` targets
- Clean separation of logs, outputs, and patches

---

## 📦 Supported Distributions
- **OpenAnolis**
- **openEuler** (`Implementing...`)

---

## ⚙️ Usage

* `make config`     - Configure target distribution
* `make build`      - Build kernel
* `make test`       - Run distro-specific tests
* `make clean`      - Remove logs/ and outputs/ 
* `make reset`      - Reset git repo to saved HEAD 
* `make distclean`  - Remove all artifacts and configs
* `make mrproper`    - Same as distclean

