#!/usr/bin/env bash

HEAD=$(git rev-parse HEAD)
OUT=$(pwd)/.regen
CONFIGS=(
  $(pwd)/arch/arm64/configs/vendor/kona-perf_defconfig
  $(pwd)/arch/arm64/configs/vendor/debugfs.config
  $(pwd)/arch/arm64/configs/vendor/oplus.config
)
export ARCH=arm64 LLVM=1 CROSS_COMPILE=aarch64-linux-gnu-

merge_config() {
  echo "==> Merging config fragments ..."
  scripts/kconfig/merge_config.sh -O $OUT ${CONFIGS[@]}
  if [ $? -ne 0 ]; then
    echo "==> ERROR: merge_config.sh failed"; exit 1;
  fi
  make O=$OUT -j$(nproc --all) savedefconfig
  if [ $? -ne 0 ]; then
    echo "==> ERROR: savedefconfig failed"; exit 1;
  fi
  cp $OUT/defconfig arch/arm64/configs/oplus_defconfig
}

regen_config() {
  echo "==> Regenerating defconfig ..."
  mkdir -p $OUT || exit 0
  make oplus_defconfig O=$OUT || exit 0
  mv $OUT/.config arch/arm64/configs/cat_defconfig || exit 0
}

mkdir -p $OUT
merge_config
regen_config
rm -rf $OUT
echo "==> Commiting ..."
git add arch/arm64/configs/cat_defconfig arch/arm64/configs/oplus_defconfig
git commit -sm "arm64: configs: Regenerate d1aznr/kernel_oppo_sm8250@${HEAD}"
