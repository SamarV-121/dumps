#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:cf25d36eea5dd1eaa17494b27591c309e712a382; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/platform/bootdevice/by-name/boot:33554432:7b991ec26405c0e73c4813d6f2c354c7834f63dc \
          --target EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:cf25d36eea5dd1eaa17494b27591c309e712a382 && \
      log -t recovery "Installing new oppo recovery image: succeeded" && \
      setprop ro.recovery.updated true || \
      log -t recovery "Installing new oppo recovery image: failed" && \
      setprop ro.recovery.updated false
else
  log -t recovery "Recovery image already installed"
  setprop ro.recovery.updated true
fi
