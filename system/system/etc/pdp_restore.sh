#!/system/bin/sh
# Copyright (c) 2016, Samsung Electronics Co., Ltd.

# PDP : Preloaded-Data Preservation

# Unzip & un-tar
if [[ -f /cache/pdp_bkup/pdp_bkup.tar.zip ]]; then
  echo "[PDP] [pdp_res____.s_]  un-zip /c pd__bku_.t__.z__ to /d /pd" > /dev/kmsg
  /system/bin/unzip /cache/pdp_bkup/pdp_bkup.tar.zip -d /data/pdp_bkup/
else
  echo "[PDP] [pdp_res____.s_]  !!! something is wrong !!  there is no PDP backup file" > /dev/kmsg
fi

if [[ -f /data/pdp_bkup/apps_apks.tar ]]; then
  echo "[PDP] [pdp_res____.s_]  un-tar ap___apk_.t__ to /d /a__" > /dev/kmsg
  /system/bin/tar -xpf /data/pdp_bkup/apps_apks.tar -C /data
else
  echo "[PDP] [pdp_res____.s_]  !!! something is wrong !!  ap___apk_.t__ file is not exist" > /dev/kmsg
fi

if [[ -d /data/pdp_bkup/META-INF ]]; then
  echo "[PDP] [pdp_res____.s_]  rm /d /p /META-INF" > /dev/kmsg
  /system/bin/rm -rf /data/pdp_bkup/META-INF
fi

# RAM-loading files
if [[ -f /data/pdp_bkup/pdp_ssapps.tar.zip ]]; then
  echo "[PDP] [pdp_res____.s_]  unzip pdp_ssapps.t__.z__ to /d /a" > /dev/kmsg
  /system/bin/unzip /data/pdp_bkup/pdp_ssapps.tar.zip -d /data/pdp_bkup/

  if [[ -f /data/pdp_bkup/pdp_ssapps.tar ]]; then
    echo "[PDP] [pdp_res____.s_]  un-tar pdp_ssapps.t__ to /d /a" > /dev/kmsg
    /system/bin/tar -xpf /data/pdp_bkup/pdp_ssapps.tar -C /data
    /system/bin/rm -f /data/pdp_bkup/pdp_ssapps.tar
  else
    echo "[PDP] [pdp_res____.s_]  !!! something is wrong !!  pdp_ssapps.t__ file is not exist" > /dev/kmsg
  fi

  if [[ -d /data/pdp_bkup/META-INF ]]; then
    echo "[PDP] [pdp_res____.s_]  rm /d /p /META-INF" > /dev/kmsg
    /system/bin/rm -rf /data/pdp_bkup/META-INF
  fi
else
  echo "[PDP] [pdp_res____.s_]  there is no pdp_ssapps.t__.z__ " > /dev/kmsg
fi


if [[ -f /data/pdp_bkup/pdp_ggapps.tar.zip ]]; then
  echo "[PDP] [pdp_res____.s_]  unzip pdp_ggapps.t__.z__ to /d /a" > /dev/kmsg
  /system/bin/unzip /data/pdp_bkup/pdp_ggapps.tar.zip -d /data/pdp_bkup/

  if [[ -f /data/pdp_bkup/pdp_ggapps.tar ]]; then
    echo "[PDP] [pdp_res____.s_]  un-tar pdp_ggapps.t__ to /d /a" > /dev/kmsg
    /system/bin/tar -xpf /data/pdp_bkup/pdp_ggapps.tar -C /data
    /system/bin/rm -f /data/pdp_bkup/pdp_ggapps.tar
  else
    echo "[PDP] [pdp_res____.s_]  !!! something is wrong !!  pdp_ggapps.t__ file is not exist" > /dev/kmsg
  fi

  if [[ -d /data/pdp_bkup/META-INF ]]; then
    echo "[PDP] [pdp_res____.s_]  rm /d /p /META-INF" > /dev/kmsg
    /system/bin/rm -rf /data/pdp_bkup/META-INF
  fi
else
  echo "[PDP] [pdp_res____.s_]  there is no pdp_ggapps.t__.z__ " > /dev/kmsg
fi

# Copy files
# -p option can preserve the additional attributes: context, links, xattr, all
echo "[PDP] [pdp_res____.s_]  mv p___bk__.t__.z__ from /c to /d" > /dev/kmsg
/system/bin/mv -f /cache/pdp_bkup/pdp_bkup.tar.zip /data/pdp_bkup/pdp_bkup.tar.zip

if [[ -f /cache/pdp_bkup/pdp_list.txt ]]; then
  echo "[PDP] [pdp_res____.s_]  mv p___li__.txt from /c to /d" > /dev/kmsg
  /system/bin/mv -f /cache/pdp_bkup/pdp_list.txt /data/pdp_bkup/pdp_list.txt
fi

# remove files
echo "[PDP] [pdp_res____.s_]  rm p___bk__.tar at /d" > /dev/kmsg
/system/bin/rm -f /data/pdp_bkup/apps_apks.tar

# echo "[PDP] [pdp_res____.s_]  rm files at /ca" > /dev/kmsg
# /system/bin/rm -f /cache/pdp_bkup/pdp_bkup.tar.gz
# /system/bin/rm -f /cache/pdp_bkup/pdp_list.txt
# /system/bin/rm -f /cache/pdp_bkup/pdp_cc_done.txt

# remove the /pdp_bkup folder at /cache : doesn't work
# echo -p i -t "[PDP] [pdp_res____.s_]  rmdir /c____/p___b___ folder" > /dev/kmsg
# /system/bin/rm -r -f /cache/pdp_bkup
