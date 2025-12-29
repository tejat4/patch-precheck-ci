# Patch Pre-Check CI Tool

This tool automates distribution detection, configuration, patch application, and kernel build/test workflows across supported Linux distributions.

---

## ✨ Features
- Automatic detection of target distribution
- Distro-specific build scripts
- Patch management and pre-check CI integration
- Automated kernel boot testing on remote VMs
- Password-based authentication for unattended testing
- Unified interface via `make` targets
- Clean separation of logs, outputs, and patches
- Web-based dashboard for monitoring and control

---

## 📦 Supported Distributions
- **OpenAnolis**
- **OpenEuler**
- **OpenCloud** (`🚧 Implementing...`)

---

## 🌐 Web Interface

A modern, responsive web interface is available for easier interaction with the tool.

### Quick Start

```bash
cd patch-precheck-ci/web
./start.sh
```

Access at: `http://your-server-ip:5000`

### Features
- 🎨 Modern purple gradient UI with real-time updates
- ⚙️ Interactive configuration wizard
- 🔨 Build progress tracking with live status
- 🧪 Individual and batch test execution
- 📊 Real-time progress bars and status indicators
- 📝 Log viewer with popup modals
- 🎯 One-click operations for all make commands

---

## ⚙️ Usage

- Install Prerequisite packages (Check in [DOCUMENT.md](https://github.com/SelamHemanth/patch-precheck-ci/blob/main/DOCUMENT.md))

```bash
# Clone repository
git clone https://github.com/SelamHemanth/patch-precheck-ci.git

# Step into investigation
cd patch-precheck-ci
```

* `make config`             - Configure target distribution
* `make build`              - Build kernel
* `make test`               - Run distro-specific tests
* `make list-tests`         - List available tests for configured distro
* `make anolis-test=<name>` - Run specific OpenAnolis test
* `make euler-test=<name>`  - Run specific openEuler test
* `make clean`              - Remove logs/ and outputs/
* `make reset`              - Reset git repo to saved HEAD
* `make distclean`          - Remove all artifacts and configs
* `make update-tests`       - Update test configuration only

---

## 📖 Documentation

For detailed documentation, please refer to: [DOCUMENT.md](https://github.com/SelamHemanth/patch-precheck-ci/blob/main/DOCUMENT.md)

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](https://github.com/SelamHemanth/patch-precheck-ci/blob/main/LICENSE) file for details.

---

## 👤 Author

**Hemanth Selam**
- GitHub: [@SelamHemanth](https://github.com/SelamHemanth)
- Email: Hemanth.Selam@amd.com
