#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:66b977821c4855f6c4f32df3e4927c4438be7795; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/platform/bootdevice/by-name/boot:33554432:1d3576427fee9e9f3087901e46737db2b4aa203d \
          --target EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:66b977821c4855f6c4f32df3e4927c4438be7795 && \
      log -t recovery "Installing new oppo recovery image: succeeded" && \
      setprop ro.recovery.updated true || \
      log -t recovery "Installing new oppo recovery image: failed" && \
      setprop ro.recovery.updated false
else
  log -t recovery "Recovery image already installed"
  setprop ro.recovery.updated true
fi
