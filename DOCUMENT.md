# Patch Pre-Check CI Tool Documentation

## Overview

The Patch Pre-Check CI Tool is an automated testing framework designed to validate Linux kernel patches across different distributions before submission. It streamlines patch validation by automating patch application, kernel builds, distribution-specific testing, and provides both command-line and web-based interfaces for enhanced usability.

## Features

- **Automated Patch Processing:** Generates patches from git commits and applies them sequentially
- **Incremental Build Testing:** Tests each patch individually to identify build-breaking changes early
- **Comprehensive Test Suite:** Configuration validation, multiple build configurations, distribution-specific testing
- **Smart Configuration:** Interactive wizard with sensible defaults
- **Password Management:** Secure storage of host and VM credentials for unattended testing
- **Clean Workflow:** Automatic git state management with rollback
- **VM Boot Verification:** Automated kernel installation, boot, and version verification on remote VMs
- **Web Interface:** Modern, responsive dashboard for monitoring and controlling all operations

## Supported Distributions

| Distribution | Target Kernel         | Kernel Versions     | Architectures  |
|--------------|-----------------------|---------------------|----------------|
| OpenAnolis   | cloud-kernel          | Multiple LTS        | x86_64         |
| openEuler    | Kernel                | Multiple LTS        | x86_64         |
| OpenCloud    | OpenCloudOS-Kernel    | Multiple LTS        | x86_64         |

## Installation & Setup

### Prerequisites

```bash
sudo yum install -y git make gcc flex bison elfutils-libelf-devel openssl-devel ncurses-devel bc rpm-build
```
OpenAnolis extra requirements
```bash
sudo yum install -y audit-libs-devel binutils-devel libbpf-devel libcap-ng-devel libnl3-devel newt-devel pciutils-devel xmlto yum-utils
```
openEuler extra requirements
```bash
sudo yum install -y python3
```

For VM boot testing:
```bash
sudo yum install -y sshpass
```

For Web Interface:
```bash
pip3 install Flask Flask-CORS Werkzeug --user
```

### Getting Started

#### Command Line Interface

```bash
git clone https://github.com/SelamHemanth/patch-precheck-ci.git
cd patch-precheck-ci

make config # Run config wizard
make build # Build/test patches
make test # Execute all tests
```

#### Web Interface

```bash
cd patch-precheck-ci/web
./start.sh
# Access at: http://your-server-ip:5000
```

### Configuration Steps

1. **Distribution Selection**

    ```
    ╔════════════════════════╗
    ║ Distribution Selection ║
    ╚════════════════════════╝
    Detected Distribution: anolis
    Available distributions:
      1) OpenAnolis
      2) openEuler
    Enter choice [1-2]:
    ```

2. **Distribution-Specific Configuration**

   **OpenAnolis:**
     - Linux source code path
     - Signed-off-by name/email
     - Anolis Bugzilla ID (ANBZ)
     - Number of patches to apply (from HEAD)
     - Build threads (default: CPU cores)

     **Test Options:**

     | Test                        | Description                  | Purpose                                  |
     |-----------------------------|------------------------------|------------------------------------------|
     | check_Kconfig               | Validate Kconfig settings    | Ensures config validity                  |
     | build_allyes_config         | Build with allyesconfig      | Compile w/ all enabled options           |
     | build_allno_config          | Build with allnoconfig       | Minimal kernel build                     |
     | build_anolis_defconfig      | Build with anolis_defconfig  | Production default config                |
     | build_anolis_debug_defconfig| Build with debug config      | Enable debugging features                |
     | anck_rpm_build              | Build ANCK RPM packages      | RPMs for installation                    |
     | check_kapi                  | Check KAPI compatibility     | ABI compatibility checks                 |
     | boot_kernel_rpm             | Automated VM boot test       | Install, boot, and verify kernel on VM   |

     Enable: individual (e.g. 1,3,5), all, or none.

   **Password Configuration** (when RPM build or boot test enabled)

   **Host Configuration:**
   - Host sudo password (for installing build dependencies)
   - Stored securely for unattended testing
   - Used for: package installation, yum-builddep

   **VM Configuration** (when boot test enabled):
   - VM IP address (bridge or local network)
   - VM root password (for SSH/SCP access)
   - Used for: RPM transfer, installation, reboot, verification

   **openEuler:**
     - Linux source code path
     - Signed-off-by name/email
     - Euler Bugzilla ID
     - Patch category (default: feature)
     - Number of patches to apply (from HEAD)
     - Build threads (default: CPU cores)

     **Test Options:**

     | Test              | Description                       | Purpose                                    |
     |-------------------|-----------------------------------|--------------------------------------------|
     | check_dependency  | Verify required dependencies      | Ensures all bug-fix commits are backported |
     | build_allmod      | Build with allmodconfig           | Compile with all modules enabled           |
     | check_patch       | Run checkpatch.pl validation      | Verify coding style and patch format       |
     | check_format      | Check code formatting             | Ensures code style consistency             |
     | rpm_build         | Build openEuler RPM packages      | RPMs for installation                      |
     | boot_kernel       | Boot test (requires remote setup) | Install, boot, and verify kernel on VM     |

     Enable: individual (e.g. 1,3,5), all, or none.

   **Password Configuration** (when RPM build or boot test enabled)

   **Host Configuration:**
   - Host sudo password (for installing build dependencies)
   - Stored securely for unattended testing
   - Used for: package installation, yum-builddep

   **VM Configuration** (when boot test enabled):
   - VM IP address (bridge or local network)
   - VM root password (for SSH/SCP access)
   - Used for: RPM transfer, installation, reboot, verification

## Make Targets

| Target             | Description                            |
|--------------------|----------------------------------------|
| config             | Interactive configuration wizard       |
| build              | Generate/apply patches & build         |
| test               | Run distribution-specific test suite   |
| list-tests         | List available tests for configured    |
| anolis-test=<name> | Run specific OpenAnolis test           |
| euler-test=<name>  | Run specific openEuler test            |
| clean              | Remove logs/build outputs              |
| reset              | Reset git to saved HEAD                |
| distclean          | Remove all artifacts/config            |
| update-tests       | Update test configuration only         |
| help               | Display usage info                     |

## Web Interface

### Overview

The web interface provides a modern, graphical dashboard for interacting with the Patch Pre-Check CI Tool without using the command line.

### Features

#### Dashboard
- **Real-time Status Display:** Shows current configuration, distribution, and system state
- **Configuration Badge:** Visual indicator of system readiness
- **Distribution Selector:** Quick switching between OpenAnolis and openEuler

#### Configuration Management
- **Interactive Form:** Multi-section wizard with validation
  - General: Kernel source, author info, bugzilla ID, patch settings
  - Build: Thread configuration
  - VM: Network and authentication settings
  - Host: Local authentication
- **View Configuration:** Display current settings with one click
- **Validation:** Client-side checks for required fields

#### Build Operations
- **Progress Tracking:** Real-time progress bars showing build status
- **Status Indicators:** Running, completed, and failed states
- **Elapsed Time:** Live tracking of operation duration
- **Log Access:** Immediate access to build logs via popup modal

#### Test Management
- **Test Grid:** Visual display of all available tests
- **Individual Execution:** Run any test with one click
- **Batch Execution:** "Run All Tests" option
- **Test Status Icons:**
  - 🔵 Spinning: Test in progress
  - ✅ Green: Test passed
  - ❌ Red: Test failed
- **Progress Tracking:** Per-test status and timing

#### Log Viewer
- **Popup Modal:** Full-screen terminal-style log display
- **Dark Theme:** Easy-to-read console output
- **Automatic Mapping:** Direct access to distribution-specific logs
- **Scrollable:** Handle large log files efficiently

#### Maintenance Operations
- **Clean:** Remove logs and build artifacts (with confirmation)
- **Reset:** Restore git repository state (double confirmation)
- **Safety Checks:** Prevent accidental data loss

### Architecture

#### Backend (Flask)
- **RESTful API:** JSON-based communication
- **Job Management:** Background task execution with threading
- **Log Mapping:** Automatic detection of distribution-specific log files
- **Configuration Storage:** Direct integration with .configure files
- **Make Integration:** Executes make commands in project root

#### Frontend (Vue.js)
- **Single Page Application:** No page reloads
- **Reactive Updates:** Auto-refresh every 2 seconds
- **Modern UI:** Purple gradient design with Font Awesome icons
- **Responsive:** Works on desktop and mobile devices
- **Modal System:** Popups for configuration, logs, and confirmations

### API Endpoints

| Endpoint                | Method | Description                    |
|-------------------------|--------|--------------------------------|
| `/api/status`           | GET    | System configuration status    |
| `/api/config/fields`    | GET    | Get form fields for distro     |
| `/api/config`           | GET    | Retrieve current configuration |
| `/api/config`           | POST   | Save configuration             |
| `/api/tests`            | GET    | List available tests           |
| `/api/build`            | POST   | Run build operation            |
| `/api/test/all`         | POST   | Run all tests                  |
| `/api/test/<name>`      | POST   | Run specific test              |
| `/api/clean`            | POST   | Clean artifacts                |
| `/api/reset`            | POST   | Reset git repository           |
| `/api/jobs`             | GET    | List all jobs                  |
| `/api/jobs/<id>`        | GET    | Get job details                |
| `/api/jobs/<id>/log`    | GET    | Get job log output             |

### Installation

```bash
# Create web directory structure
mkdir -p web/templates

# Copy files
cp server.py web/
cp start.sh web/
cp requirements.txt web/
cp index.html web/templates/

# Make launcher executable
chmod +x web/start.sh

# Install dependencies
pip3 install -r web/requirements.txt --user

# Start server
cd web
./start.sh
```

### Usage

1. **Start Server:**
   ```bash
   cd web
   ./start.sh
   ```

2. **Access Dashboard:**
   - Open browser: `http://server-ip:5000`

3. **Configure System:**
   - Select distribution (OpenAnolis or openEuler)
   - Click "Configure System"
   - Fill in all required fields
   - Save configuration

4. **Run Operations:**
   - Click "Run Build" to build patches
   - Select individual tests or "Run All Tests"
   - Monitor progress in real-time
   - View logs with one click

5. **Maintenance:**
   - Use "Clean" to remove temporary files
   - Use "Reset" to restore git state

### Security Considerations

#### Network Access
- Server binds to `0.0.0.0:5000` by default
- Configure firewall: `sudo firewall-cmd --add-port=5000/tcp --permanent`
- Consider using reverse proxy (Nginx) for HTTPS
- Restrict access to trusted networks

#### Authentication
- Currently no authentication implemented
- Suitable for isolated lab networks
- For production: implement API key or OAuth

#### Password Storage
- Passwords stored in `.configure` files
- Same security concerns as CLI interface
- Consider using SSH keys for VM access

### Troubleshooting

**Frontend Not Loading:**
```bash
# Check if index.html exists
ls -la web/templates/index.html

# Check server logs for path errors
```

**Logs Not Displaying:**
```bash
# Verify logs directory exists
ls -la logs/

# Run a test to generate logs
make anolis-test=check_kconfig

# Check log file was created
ls -la logs/check_Kconfig.log
```

**Cannot Access from Network:**
```bash
# Open firewall
sudo firewall-cmd --add-port=5000/tcp --permanent
sudo firewall-cmd --reload

# Check port is listening
sudo netstat -tulpn | grep 5000
```

**Module Not Found:**
```bash
# Install dependencies
pip3 install -r web/requirements.txt --user --break-system-packages
```

## Security Considerations

### Password Storage
- Passwords are stored in plaintext in `.configure` file
- File permissions should be restricted: `chmod 600 anolis/.configure`
- **Do not commit `.configure` to version control**
- Consider using SSH keys for production environments

### SSH Configuration
- Currently uses `StrictHostKeyChecking=no` for automation
- For production, configure proper SSH key authentication
- Use known_hosts verification in secure environments

### Web Interface Security
- No authentication by default
- Suitable for trusted networks only
- Consider implementing authentication for production
- Use HTTPS with reverse proxy in production
- Restrict firewall access to known IPs

## Contributing

To add a new distribution:

- Create: `newdistro/` directory
- Add: `config.sh`, `build.sh`, `test.sh`, `Makefile`
- Update: main `Makefile` with new targets
- Implement boot testing if supported
- Thoroughly test all features
- Submit pull request

## License

GPL-3.0 licence

This tool is provided as-is for kernel development and testing purposes.

## Support

- [Repository](https://github.com/SelamHemanth/patch-precheck-ci)
- Issues via GitHub

---
