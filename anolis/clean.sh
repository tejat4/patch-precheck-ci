#!/usr/bin/env bash
set -uo pipefail

# anolis/clean.sh - OpenAnolis specific cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(dirname "$SCRIPT_DIR")"

# Load configuration if exists
CONFIG_FILE="${WORKDIR}/.configure"
if [ -f "${CONFIG_FILE}" ]; then
  # shellcheck disable=SC1090
  . "${CONFIG_FILE}"
fi

echo "Cleaning OpenAnolis specific artifacts..."

# Clean anolis directory outputs
if [ -n "${LINUX_SRC_PATH:-}" ] && [ -d "${LINUX_SRC_PATH}/anolis" ]; then
  echo "  → Cleaning ${LINUX_SRC_PATH}/anolis/outputs"
  rm -rf "${LINUX_SRC_PATH}/anolis/outputs"
  rm -rf "${LINUX_SRC_PATH}/anolis/output"
  rm -f "${LINUX_SRC_PATH}/anolis/cloud-kernel"
  rm -f "${LINUX_SRC_PATH}/anolis/.deps_installed"
fi

# Clean kernel build artifacts
if [ -n "${LINUX_SRC_PATH:-}" ] && [ -d "${LINUX_SRC_PATH}" ]; then
  echo "  → Cleaning kernel build artifacts"
  cd "${LINUX_SRC_PATH}"
  make clean > /dev/null 2>&1 || true
  make mrproper > /dev/null 2>&1 || true
fi

echo "OpenAnolis cleanup complete"
