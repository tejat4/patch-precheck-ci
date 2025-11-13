#!/usr/bin/env bash
set -uo pipefail

# anolis/test.sh - OpenAnolis CI Test Suite

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(dirname "$SCRIPT_DIR")"

# Load configuration
CONFIG_FILE="${SCRIPT_DIR}/.configure"
DISTRO_CONFIG="${WORKDIR}/.distro_config"

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "Error: Configuration file not found: ${CONFIG_FILE}" >&2
  echo "Run 'make config' first." >&2
  exit 1
fi

# shellcheck disable=SC1090
. "${CONFIG_FILE}"

if [ -f "${DISTRO_CONFIG}" ]; then
  . "${DISTRO_CONFIG}"
fi

LOGS_DIR="${WORKDIR}/logs"
TEST_LOG="${LOGS_DIR}/test_results.log"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

: "${LINUX_SRC_PATH:?missing in config}"

mkdir -p "${LOGS_DIR}"

echo ""
echo -e "${BLUE}=============================${NC}"
echo -e "${BLUE}OpenAnolis Build & Test Suite${NC}"
echo -e "${BLUE}=============================${NC}"
echo ""

# Counters
TEST_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

if [ $(arch) == "x86_64" ]; then
  kernel_arch="x86"
elif [ $(arch) == "aarch64" ]; then
  kernel_arch="arm64"
else
  echo -e "${RED}Error: Not supported arch${NC}"
  exit 1
fi

pass() {
  local test_name="$1"
  echo -e "${GREEN}✓ PASS${NC}: ${test_name}"
  TEST_RESULTS+=("PASS:${test_name}")
  ((PASSED_TESTS++))
  ((TOTAL_TESTS++))
}

fail() {
  local test_name="$1"
  local reason="${2:-}"
  echo -e "${RED}✗ FAIL${NC}: ${test_name}"
  [ -n "$reason" ] && echo -e "  Reason: ${reason}"
  TEST_RESULTS+=("FAIL:${test_name}")
  ((FAILED_TESTS++))
  ((TOTAL_TESTS++))
}

skip() {
  local test_name="$1"
  local reason="${2:-}"
  echo -e "${YELLOW}⊘ SKIP${NC}: ${test_name}"
  [ -n "$reason" ] && echo -e "  Reason: ${reason}"
  TEST_RESULTS+=("SKIP:${test_name}")
  ((SKIPPED_TESTS++))
  ((TOTAL_TESTS++))
}

# Common function to build kernel with given config target
run_kernel_build() {
  local test_name="$1"
  local config_target="$2"
  echo -e "${BLUE}Test: ${test_name}${NC}"
  cd "${LINUX_SRC_PATH}"

  make clean > /dev/null 2>&1
  echo "  → Building kernel with ${config_target}..."
  if make "${config_target}" > "${LOGS_DIR}/${test_name}.log" 2>&1 \
    && make -j"$(nproc)" >> "${LOGS_DIR}/${test_name}.log" 2>&1 \
    && make modules -j"$(nproc)" >> "${LOGS_DIR}/${test_name}.log" 2>&1; then
    pass "${test_name}"
  else
    fail "${test_name}" "Build failed (see ${LOGS_DIR}/${test_name}.log)"
  fi
  echo ""
}

# ---- TEST DEFINITIONS ----

test_check_kconfig() {
  echo -e "${BLUE}Test: check_Kconfig${NC}"
  cd "${LINUX_SRC_PATH}/anolis" 2>/dev/null || {
    skip "check_Kconfig" "anolis/ directory not found"
    return
  }

  mkdir -p "${LINUX_SRC_PATH}/anolis/output" 2>/dev/null
  chmod -R u+w "${LINUX_SRC_PATH}/anolis/output" 2>/dev/null || true

  if ARCH=${kernel_arch} make dist-configs-check > "${LOGS_DIR}/check_Kconfig.log" 2>&1; then
    pass "check_Kconfig"
  else
    fail "check_Kconfig" "dist-configs-check failed (see ${LOGS_DIR}/check_Kconfig.log)"
  fi
  echo ""
}

test_build_allyes_config() {
  run_kernel_build "build_allyes_config" "allyesconfig"
}

test_build_allno_config() {
  run_kernel_build "build_allno_config" "allnoconfig"
}

test_build_anolis_defconfig() {
  run_kernel_build "build_anolis_defconfig" "anolis_defconfig"
}

test_build_anolis_debug_defconfig() {
  run_kernel_build "build_anolis_debug_defconfig" "anolis-debug_defconfig"
}

test_anck_rpm_build() {
  echo -e "${BLUE}Test: anck_rpm_build${NC}"
  echo "== Build Kernel RPM =="

  # Check and install required build dependencies only if missing
  local packages="audit-libs-devel binutils-devel libbpf-devel libcap-ng-devel libnl3-devel newt-devel pciutils-devel xmlto yum-utils"
  local missing_packages=""

  for pkg in $packages; do
    if ! rpm -q "$pkg" &>/dev/null; then
      missing_packages="$missing_packages $pkg"
    fi
  done

  if [ -n "$missing_packages" ]; then
    echo "Installing missing packages:$missing_packages"
    sudo yum install -y $missing_packages >> "${LOGS_DIR}/anck_rpm_build.log" 2>&1 || true
  fi

  # Set build environment variables
  export BUILD_NUMBER="${BUILD_NUMBER:-0}"
  export BUILD_MODE="${BUILD_MODE:-devel}"
  export BUILD_VARIANT="${BUILD_VARIANT:-default}"
  export BUILD_EXTRA="${BUILD_EXTRA:-debuginfo}"

  cd "${LINUX_SRC_PATH}/anolis" || {
    fail "anck_rpm_build" "Cannot enter anolis directory"
    return
  }

  # Create symlink to kernel source if not exists
  [ ! -L "cloud-kernel" ] && ln -sf "${LINUX_SRC_PATH}" cloud-kernel

  # Create and clean outputs directory
  outputdir="${LINUX_SRC_PATH}/anolis/outputs"
  rm -rf "${outputdir}/rpmbuild"
  mkdir -p "${outputdir}"

  # Generate spec file if not exists or outdated
  if [ ! -f output/kernel.spec ] || [ "${LINUX_SRC_PATH}/anolis/Makefile" -nt output/kernel.spec ]; then
    make dist-genspec >> "${LOGS_DIR}/anck_rpm_build.log" 2>&1 || {
      fail "anck_rpm_build" "make dist-genspec failed"
      return
    }
  fi

  # Install spec dependencies only once
  if [ ! -f "${outputdir}/.deps_installed" ]; then
    sudo yum-builddep -y output/kernel.spec >> "${LOGS_DIR}/anck_rpm_build.log" 2>&1 || true
    touch "${outputdir}/.deps_installed"
  fi

  # Downgrade binutils only if needed
  if rpm -q binutils-2.40 &>/dev/null || rpm -q binutils-2.41 &>/dev/null; then
    echo "Downgrading binutils to 2.39*"
    sudo yum downgrade -y binutils-2.39* >> "${LOGS_DIR}/anck_rpm_build.log" 2>&1 || true
  fi

  # Set ulimit and build
  ulimit -n 65535

  echo "Building ANCK RPMs..."
  if DIST=".an23" \
     DIST_BUILD_NUMBER=${BUILD_NUMBER} \
     DIST_OUTPUT=${outputdir} \
     DIST_BUILD_MODE=${BUILD_MODE} \
     DIST_BUILD_VARIANT=${BUILD_VARIANT} \
     DIST_BUILD_EXTRA=${BUILD_EXTRA} \
     make dist-rpms RPMBUILDOPTS="--define '%_smp_mflags -j16'" \
     >> "${LOGS_DIR}/anck_rpm_build.log" 2>&1; then
    pass "anck_rpm_build"
  else
    fail "anck_rpm_build" "RPM build failed (see ${LOGS_DIR}/anck_rpm_build.log)"
  fi

  echo ""
}

test_boot_kernel_rpm() {
  echo -e "${BLUE}Test: boot_kernel_rpm${NC}"
  skip "boot_kernel_rpm" "Install the build rpm and install it manually."
  echo ""
}

test_check_kapi() {
  echo -e "${BLUE}Test: check_kapi${NC}"
  skip "check_kapi" "Not Implemented. Coming soon."
  echo ""
}

# ---- TEST EXECUTION ----

[ "$TEST_CHECK_KCONFIG" == "yes" ] && test_check_kconfig
[ "$TEST_BUILD_ALLYES" == "yes" ] && test_build_allyes_config
[ "$TEST_BUILD_ALLNO" == "yes" ] && test_build_allno_config
[ "$TEST_BUILD_DEFCONFIG" == "yes" ] && test_build_anolis_defconfig
[ "$TEST_BUILD_DEBUG" == "yes" ] && test_build_anolis_debug_defconfig
[ "$TEST_RPM_BUILD" == "yes" ] && test_anck_rpm_build
[ "$TEST_CHECK_KAPI" == "yes" ] && test_check_kapi
[ "$TEST_BOOT_KERNEL" == "yes" ] && test_boot_kernel_rpm

# ---- SUMMARY ----
{
  echo "OpenAnolis Test Report"
  echo "======================"
  echo "Date: $(date)"
  echo "Kernel Source: ${LINUX_SRC_PATH}"
  echo ""
  echo "Test Results:"
  echo "-------------"
  for result in "${TEST_RESULTS[@]}"; do
    echo "$result"
  done
  echo ""
  echo "Summary:"
  echo "--------"
  echo "Total Tests: ${TOTAL_TESTS}"
  echo "Passed: ${PASSED_TESTS}"
  echo "Failed: ${FAILED_TESTS}"
  echo "Skipped: ${SKIPPED_TESTS}"
} > "${TEST_LOG}"

echo -e "${GREEN}============${NC}"
echo -e "${GREEN}Test Summary${NC}"
echo -e "${GREEN}============${NC}"
echo "Total Tests: ${TOTAL_TESTS}"
echo -e "Passed:  ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Failed:  ${RED}${FAILED_TESTS}${NC}"
echo -e "Skipped: ${YELLOW}${SKIPPED_TESTS}${NC}"
echo ""
echo -e "${BLUE}Full report: ${TEST_LOG}${NC}"
echo ""

if [ "${FAILED_TESTS}" -gt 0 ]; then
  echo -e "${RED}✗ Some tests failed${NC}"
  exit 1
else
  echo -e "${GREEN}✓ All tests passed or skipped${NC}"
  exit 0
fi
