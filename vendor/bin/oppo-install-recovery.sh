#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:e0dc99bab3b1b5fb15e23382bbe9f926424fb5b5; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/platform/bootdevice/by-name/boot:33554432:558ae49ea74c4b49e6f1a16bd421aa2766b738e0 \
          --target EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:e0dc99bab3b1b5fb15e23382bbe9f926424fb5b5 && \
      log -t recovery "Installing new oppo recovery image: succeeded" && \
      setprop ro.recovery.updated true || \
      log -t recovery "Installing new oppo recovery image: failed" && \
      setprop ro.recovery.updated false
else
  log -t recovery "Recovery image already installed"
  setprop ro.recovery.updated true
fi
