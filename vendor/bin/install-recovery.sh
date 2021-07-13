#!/vendor/bin/sh
if ! applypatch --check EMMC:/dev/block/by-name/recovery$(getprop ro.boot.slot_suffix):67108864:ab9fa75d56389f0d150e9fac0dc8c14eeeb83870; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/by-name/boot$(getprop ro.boot.slot_suffix):33554432:f679cf6d087d04507ec511c4478b5333e0d2a259 \
          --target EMMC:/dev/block/by-name/recovery$(getprop ro.boot.slot_suffix):67108864:ab9fa75d56389f0d150e9fac0dc8c14eeeb83870 && \
      log -t recovery "Installing new recovery image: succeeded" && \
      setprop ro.boot.recovery.updated true || \
      log -t recovery "Installing new recovery image: failed" && \
      setprop ro.boot.recovery.updated false
else
  log -t recovery "Recovery image already installed"
  setprop ro.boot.recovery.updated true
fi
