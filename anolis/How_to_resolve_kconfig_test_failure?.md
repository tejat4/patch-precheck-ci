# Resolving Kconfig UNKNOWN Config Classification Issue

This document outlines a generic process to resolve `check_Kconfig` failures caused by configs being placed in the `UNKNOWN` classification during baseline refresh.

## Problem Statement

During CI testing, errors may occur when some config symbols are classified as `UNKNOWN` level, causing baseline checks to fail.

Example error:

```
✗ FAIL: check_Kconfig
Reason: dist-configs-check failed
There are some UNKNOWN level's new configs.
CONFIG_SYMBOL_NAME
```

This indicates that `CONFIG_SYMBOL_NAME` is placed under `configs/UNKNOWN`.

## Root Cause

* The config symbol is defined in a specific architecture or subsystem Kconfig file.
* It has dependencies that may not be satisfied during config refresh.
* When dependencies are not met, the symbol is classified as `UNKNOWN`.

## Generic Resolution Steps

### 1. Identify Unknown Configs

```bash
# List all config symbols currently classified as UNKNOWN
cd <Anolis Linux Code>
grep -R "^CONFIG_" anolis/configs/UNKNOWN
```

List all symbols currently classified as UNKNOWN.

### 2. Analyze Config Scope and Dependencies

* Determine the architecture or subsystem scope of the config.
* Check the dependencies that control its visibility.
* Decide the appropriate classification level (e.g., L1-RECOMMEND, L2-OPTIONAL).

### 3. Move Configs Out of UNKNOWN

From the top-level directory:

```bash
cd anolis
make dist-configs-move C=CONFIG_SYMBOL_NAME L=LEVEL
```

Replace `CONFIG_SYMBOL_NAME` with the actual symbol and `LEVEL` with the desired classification.

### 4. Refresh Configurations

Run:

```bash
make dist-configs-update
```

This regenerates the configs with updated classifications.

### 5. Verify Classification

Check that the config symbol is moved to the correct level and UNKNOWN is empty:

```bash
ls configs/LEVEL/path/CONFIG_SYMBOL_NAME
ls configs/UNKNOWN
```

### 6. Run Baseline Checks

Run the baseline checks using the `make test` command in your tool:

```bash
make test
```

This command runs the baseline tests to verify that the classification changes resolved the UNKNOWN config issues. Ensure no errors remain after this step.

### 7. Commit Changes

```bash
git add configs/LEVEL/path/CONFIG_SYMBOL_NAME
git commit -s -m "anolis: configs: classify CONFIG_SYMBOL_NAME as LEVEL for appropriate scope"

#Add the description
git commit --amend

#Example:
# ANBZ: #12345
#
# This commit classifies CONFIG_SYMBOL_NAME as LEVEL
# for x86 AMD64 in anolis configs and aligns with upstream
# commit <SHAID> ("<SUBJECT>").
```

## 8. Push for Pull requiest

Push the fix patch for PR along with main patches

```bash
git push <remote> <branch> --force
```
