#!/bin/bash
set -e
# S21 SM-G9910 CHN_15 KVM kernel build
# Official toolchain: clang 11 (CONFIG_CLANG_VERSION=110002 in defconfig) + gcc 4.9 cross
# Install clang-11 from apt.llvm.org if not present
if ! command -v clang-11 >/dev/null 2>&1; then
  wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
  echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-11 main" | sudo tee /etc/apt/sources.list.d/llvm11.list
  sudo apt-get update && sudo apt-get install -y clang-11 lld-11 llvm-11
fi
# gcc-4.9 cross (LineageOS prebuilt, matches stock kernel gcc 4.9.x)
if [ ! -d gcc-4.9 ]; then
  git clone --depth 1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc-4.9
fi
# Samsung source (public download, no login)
if [ ! -f SM-G9910_CHN_15_Opensource.zip ]; then
  echo "Download SM-G9910_CHN_15_Opensource.zip from https://opensource.samsung.com/uploadSearch?searchValue=SM-G9910 and place it here, then re-run."
  exit 1
fi
unzip -o SM-G9910_CHN_15_Opensource.zip
tar -xzf Kernel.tar.gz
# GHZE1 update (49 files)
unzip -o SM-G9910_CHN_15_Opensource_G9910ZCSGHZB1_G9910ZCUGHZE1.zip -d ghze1
tar -xzf ghze1/G9910ZCSGHZB1_kernel.tar.gz
cp -rf Kernel/* . && rm -rf Kernel ghze1
# Enable KVM, keep LTO/CFI on (official clang 11 supports them)
cp arch/arm64/configs/vendor/o1q_chn_openx_defconfig arch/arm64/configs/vendor/s21_kvm_defconfig
sed -i 's/# CONFIG_VIRTUALIZATION is not set/CONFIG_VIRTUALIZATION=y\nCONFIG_KVM=y\nCONFIG_KVM_ARM_HOST=y\nCONFIG_KVM_ARM_VGIC_V3=y\nCONFIG_KVM_ARM_VGIC_V2=y/' arch/arm64/configs/vendor/s21_kvm_defconfig
export ARCH=arm64
make O=out DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$(pwd)/gcc-4.9/bin/aarch64-linux-android- REAL_CC=/usr/bin/clang-11 vendor/s21_kvm_defconfig
make -j$(nproc) O=out DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$(pwd)/gcc-4.9/bin/aarch64-linux-android- REAL_CC=/usr/bin/clang-11 CONFIG_SECTION_MISMATCH_WARN_ONLY=y
ls -lh out/arch/arm64/boot/Image
grep -E "CONFIG_VIRTUALIZATION|CONFIG_KVM" out/.config
echo "BUILD DONE"
