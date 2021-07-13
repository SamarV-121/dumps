#! /system/bin/sh

CURTIME=`date +%F_%H-%M-%S`
CURTIME_FORMAT=`date "+%Y-%m-%d %H:%M:%S"`

BASE_PATH=/sdcard
SDCARD_LOG_BASE_PATH=${BASE_PATH}/Android/data/com.coloros.logkit/files/Log
SDCARD_LOG_TRIGGER_PATH=${SDCARD_LOG_BASE_PATH}/trigger

ANR_BINDER_PATH=/data/oppo_log/anr_binder_info
DATA_LOG_PATH=/data/oppo_log
CACHE_PATH=/data/oppo_log/cache

config="$1"

#Linjie.Xu@PSW.AD.Power.PowerMonitor.1104067, 2018/01/17, Add for OppoPowerMonitor get dmesg at O
function kernelcacheforopm(){
  opmlogpath=`getprop sys.opm.logpath`
  dmesg > ${opmlogpath}dmesg.txt
  chown system:system ${opmlogpath}dmesg.txt
}
#Linjie.Xu@PSW.AD.Power.PowerMonitor.1104067, 2018/01/17, Add for OppoPowerMonitor get Sysinfo at O
function psforopm(){
  opmlogpath=`getprop sys.opm.logpath`
  ps -A -T > ${opmlogpath}psO.txt
  chown system:system ${opmlogpath}psO.txt
}
function cpufreqforopm(){
  opmlogpath=`getprop sys.opm.logpath`
  cat /sys/devices/system/cpu/*/cpufreq/scaling_cur_freq > ${opmlogpath}cpufreq.txt
  chown system:system ${opmlogpath}cpufreq.txt
}


function logcatMainCacheForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  logcat -v threadtime -d > ${opmlogpath}logcat.txt
  chown system:system ${opmlogpath}logcat.txt
}

function logcatEventCacheForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  logcat -b events -d > ${opmlogpath}events.txt
  chown system:system ${opmlogpath}events.txt
}

function logcatRadioCacheForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  logcat -b radio -d > ${opmlogpath}radio.txt
  chown system:system ${opmlogpath}radio.txt
}

function catchBinderInfoForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  cat /sys/kernel/debug/binder/state > ${opmlogpath}binderinfo.txt
  chown system:system ${opmlogpath}binderinfo.txt
}

function catchBattertFccForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  cat /sys/class/power_supply/battery/batt_fcc > ${opmlogpath}fcc.txt
  chown system:system ${opmlogpath}fcc.txt
}

function catchTopInfoForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  opmfilename=`getprop sys.opm.logpath.filename`
  top -H -n 3 > ${opmlogpath}${opmfilename}top.txt
  chown system:system ${opmlogpath}${opmfilename}top.txt
}

function dumpsysSurfaceFlingerForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  dumpsys sensorservice > ${opmlogpath}sensorservice.txt
  chown system:system ${opmlogpath}sensorservice.txt
}

function dumpsysSensorserviceForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  dumpsys sensorservice > ${opmlogpath}sensorservice.txt
  chown system:system ${opmlogpath}sensorservice.txt
}

function dumpsysBatterystatsForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  dumpsys batterystats > ${opmlogpath}batterystats.txt
  chown system:system ${opmlogpath}batterystats.txt
}

function dumpsysBatterystatsOplusCheckinForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  dumpsys batterystats --oppoCheckin > ${opmlogpath}batterystats_oplusCheckin.txt
  chown system:system ${opmlogpath}batterystats_oplusCheckin.txt
}

function dumpsysBatterystatsCheckinForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  dumpsys batterystats -c > ${opmlogpath}batterystats_checkin.txt
  chown system:system ${opmlogpath}batterystats_checkin.txt
}

function dumpsysMediaForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  dumpsys media.audio_flinger > ${opmlogpath}audio_flinger.txt
  dumpsys media.audio_policy > ${opmlogpath}audio_policy.txt
  dumpsys audio > ${opmlogpath}audio.txt

  chown system:system ${opmlogpath}audio_flinger.txt
  chown system:system ${opmlogpath}audio_policy.txt
  chown system:system ${opmlogpath}audio.txt
}

function getPropForOpm(){
  opmlogpath=`getprop sys.opm.logpath`
  getprop > ${opmlogpath}prop.txt
  chown system:system ${opmlogpath}prop.txt
}

function logcusMainForOpm() {
    opmlogpath=`getprop sys.opm.logpath`
    /system/bin/logcat -f ${opmlogpath}/android.txt -r 10240 -n 5 -v threadtime *:V
}

function logcusEventForOpm() {
    opmlogpath=`getprop sys.opm.logpath`
    /system/bin/logcat -b events -f ${opmlogpath}/event.txt -r 10240 -n 5 -v threadtime *:V
}

function logcusRadioForOpm() {
    opmlogpath=`getprop sys.opm.logpath`
    /system/bin/logcat -b radio -f ${opmlogpath}/radio.txt -r 10240 -n 5 -v threadtime *:V
}

function logcusKernelForOpm() {
    opmlogpath=`getprop sys.opm.logpath`
    /system/system_ext/xbin/klogd -f - -n -x -l 7 | tee - ${opmlogpath}/kernel.txt | awk 'NR%400==0'
}

function logcusTCPForOpm() {
    opmlogpath=`getprop sys.opm.logpath`
    tcpdump -i any -p -s 0 -W 1 -C 50 -w ${opmlogpath}/tcpdump.pcap
}

function customDiaglogForOpm() {
    echo "customdiaglog opm begin"
    opmlogpath=`getprop sys.opm.logpath`
    mv /data/oppo_log/diag_logs ${opmlogpath}
    chmod 777 -R ${opmlogpath}
    restorecon -RF ${opmlogpath}
    echo "customdiaglog opm end"
}

function dmaprocsforhealth(){
  opmlogpath=`getprop sys.opm.logpath`
  cat /sys/kernel/debug/ion/heaps/* > ${opmlogpath}dmaprocs.txt
  cat /sys/kernel/debug/ion/client_history >> ${opmlogpath}dmaprocs.txt
  cat /sys/kernel/debug/ion/ion_mm_heap >> ${opmlogpath}dmaprocs.txt
  cat /sys/kernel/debug/ion/string_hash >> ${opmlogpath}dmaprocs.txt
  dumpsys meminfo `ps -A | grep graphics.composer | tr -s ' ' | cut -d ' ' -f 2` >> ${opmlogpath}dmaprocs.txt
  chown system:system ${opmlogpath}dmaprocs.txt
}
function slabinfoforhealth(){
  opmlogpath=`getprop sys.opm.logpath`
  cat /proc/slabinfo > ${opmlogpath}slabinfo.txt
  chown system:system ${opmlogpath}slabinfo.txt
}
function meminfoforhealth(){
  opmlogpath=`getprop sys.opm.logpath`
  cat /proc/meminfo > ${opmlogpath}meminfo.txt
  chown system:system ${opmlogpath}meminfo.txt
}

# Add for SurfaceFlinger Layer dump
function layerdump(){
    dumpsys window > /data/log/dumpsys_window.txt
    mkdir -p ${SDCARD_LOG_BASE_PATH}
    LOGTIME=`date +%F-%H-%M-%S`
    ROOT_SDCARD_LAYERDUMP_PATH=${SDCARD_LOG_BASE_PATH}/LayerDump_${LOGTIME}
    cp -R /data/log ${ROOT_SDCARD_LAYERDUMP_PATH}
    rm -rf /data/log
}

#Fei.Mo2017/09/01 ,Add for power monitor top info
function thermalTop(){
   top -m 3 -n 1 > /data/system/dropbox/thermalmonitor/top
   chown system:system /data/system/dropbox/thermalmonitor/top
}

#Deliang.Peng 2017/7/7,add for native watchdog
function nativedump() {
    LOGTIME=`date +%F-%H-%M-%S`
    SWTPID=`getprop debug.swt.pid`
    JUNKLOGSFBACKPATH=/sdcard/oppo_log/native/${LOGTIME}
    NATIVEBACKTRACEPATH=${JUNKLOGSFBACKPATH}/user_backtrace
    mkdir -p ${NATIVEBACKTRACEPATH}
    cat proc/stat > ${JUNKLOGSFBACKPATH}/proc_stat.txt &
    cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_0_.txt &
    cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_1.txt &
    cat /sys/devices/system/cpu/cpu2/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_2.txt &
    cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_3.txt &
    cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_4.txt &
    cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_5.txt &
    cat /sys/devices/system/cpu/cpu6/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_6.txt &
    cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_cur_freq > ${JUNKLOGSFBACKPATH}/cpu_freq_7.txt &
    cat /sys/devices/system/cpu/cpu0/online > ${JUNKLOGSFBACKPATH}/cpu_online_0_.txt &
    cat /sys/devices/system/cpu/cpu1/online > ${JUNKLOGSFBACKPATH}/cpu_online_1_.txt &
    cat /sys/devices/system/cpu/cpu2/online > ${JUNKLOGSFBACKPATH}/cpu_online_2_.txt &
    cat /sys/devices/system/cpu/cpu3/online > ${JUNKLOGSFBACKPATH}/cpu_online_3_.txt &
    cat /sys/devices/system/cpu/cpu4/online > ${JUNKLOGSFBACKPATH}/cpu_online_4_.txt &
    cat /sys/devices/system/cpu/cpu5/online > ${JUNKLOGSFBACKPATH}/cpu_online_5_.txt &
    cat /sys/devices/system/cpu/cpu6/online > ${JUNKLOGSFBACKPATH}/cpu_online_6_.txt &
    cat /sys/devices/system/cpu/cpu7/online > ${JUNKLOGSFBACKPATH}/cpu_online_7_.txt &
    cat /proc/gpufreq/gpufreq_var_dump > ${JUNKLOGSFBACKPATH}/gpuclk.txt &
    top -n 1 -m 5 > ${JUNKLOGSFBACKPATH}/top.txt  &
    cp -R /data/native/* ${NATIVEBACKTRACEPATH}
    rm -rf /data/native
    ps -t > ${JUNKLOGSFBACKPATH}/pst.txt
}

function gettpinfo() {
    tplogflag=`getprop persist.sys.oppodebug.tpcatcher`
    # tplogflag=511
    # echo "$tplogflag"
    if [ "$tplogflag" == "" ]
    then
        echo "tplogflag == error"
    else
        subtime=`date +%F-%H-%M-%S`
        subpath=/sdcard/tp_debug_info.txt
        echo "tplogflag = $tplogflag"
        # tplogflag=`echo $tplogflag | $XKIT awk '{print lshift($0, 1)}'`
        tpstate=0
        tpstate=`echo $tplogflag | $XKIT awk '{print and($1, 1)}'`
        echo "switch tpstate = $tpstate"
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off"
        else
            echo "switch tpstate on"
        # mFlagMainRegister = 1 << 1
        subflag=`echo | $XKIT awk '{print lshift(1, 1)}'`
        echo "1 << 1 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagMainRegister = 1 << 1 $tpstate"
        else
            echo "switch tpstate on mFlagMainRegister = 1 << 1 $tpstate"
            echo "Time : ${subtime}" >> $subpath
            echo /proc/touchpanel/debug_info/main_register  >> $subpath
            cat /proc/touchpanel/debug_info/main_register  >> $subpath
        fi
        # mFlagSelfDelta = 1 << 2;
        subflag=`echo | $XKIT awk '{print lshift(1, 2)}'`
        echo " 1<<2 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagSelfDelta = 1 << 2 $tpstate"
        else
            echo "switch tpstate on mFlagSelfDelta = 1 << 2 $tpstate"
            echo /proc/touchpanel/debug_info/self_delta  >> $subpath
            cat /proc/touchpanel/debug_info/self_delta  >> $subpath
        fi
        # mFlagDetal = 1 << 3;
        subflag=`echo | $XKIT awk '{print lshift(1, 3)}'`
        echo "1 << 3 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagDelta = 1 << 3 $tpstate"
        else
            echo "switch tpstate on mFlagDelta = 1 << 3 $tpstate"
            echo /proc/touchpanel/debug_info/delta  >> $subpath
            cat /proc/touchpanel/debug_info/delta  >> $subpath
        fi
        # mFlatSelfRaw = 1 << 4;
        subflag=`echo | $XKIT awk '{print lshift(1, 4)}'`
        echo "1 << 4 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagSelfRaw = 1 << 4 $tpstate"
        else
            echo "switch tpstate on mFlagSelfRaw = 1 << 4 $tpstate"
            echo /proc/touchpanel/debug_info/self_raw  >> $subpath
            cat /proc/touchpanel/debug_info/self_raw  >> $subpath
        fi
        # mFlagBaseLine = 1 << 5;
        subflag=`echo | $XKIT awk '{print lshift(1, 5)}'`
        echo "1 << 5 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagBaseline = 1 << 5 $tpstate"
        else
            echo "switch tpstate on mFlagBaseline = 1 << 5 $tpstate"
            echo /proc/touchpanel/debug_info/baseline  >> $subpath
            cat /proc/touchpanel/debug_info/baseline  >> $subpath
        fi
        # mFlagDataLimit = 1 << 6;
        subflag=`echo | $XKIT awk '{print lshift(1, 6)}'`
        echo "1 << 6 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagDataLimit = 1 << 6 $tpstate"
        else
            echo "switch tpstate on mFlagDataLimit = 1 << 6 $tpstate"
            echo /proc/touchpanel/debug_info/data_limit  >> $subpath
            cat /proc/touchpanel/debug_info/data_limit  >> $subpath
        fi
        # mFlagReserve = 1 << 7;
        subflag=`echo | $XKIT awk '{print lshift(1, 7)}'`
        echo "1 << 7 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagReserve = 1 << 7 $tpstate"
        else
            echo "switch tpstate on mFlagReserve = 1 << 7 $tpstate"
            echo /proc/touchpanel/debug_info/reserve  >> $subpath
            cat /proc/touchpanel/debug_info/reserve  >> $subpath
        fi
        # mFlagTpinfo = 1 << 8;
        subflag=`echo | $XKIT awk '{print lshift(1, 8)}'`
        echo "1 << 8 subflag = $subflag"
        tpstate=`echo $tplogflag $subflag, | $XKIT awk '{print and($1, $2)}'`
        if [ $tpstate == "0" ]
        then
            echo "switch tpstate off mFlagMainRegister = 1 << 8 $tpstate"
        else
            echo "switch tpstate on mFlagMainRegister = 1 << 8 $tpstate"
        fi

        echo $tplogflag " end else"
	fi
    fi
}

function inittpdebug(){
    panicstate=`getprop persist.sys.assert.panic`
    tplogflag=`getprop persist.sys.oppodebug.tpcatcher`
    if [ "$panicstate" == "true" ]
    then
        tplogflag=`echo $tplogflag , | $XKIT awk '{print or($1, 1)}'`
    else
        tplogflag=`echo $tplogflag , | $XKIT awk '{print and($1, 510)}'`
    fi
    setprop persist.sys.oppodebug.tpcatcher $tplogflag
}
function settplevel(){
    tplevel=`getprop persist.sys.oppodebug.tplevel`
    if [ "$tplevel" == "0" ]
    then
        echo 0 > /proc/touchpanel/debug_level
    elif [ "$tplevel" == "1" ]
    then
        echo 1 > /proc/touchpanel/debug_level
    elif [ "$tplevel" == "2" ]
    then
        echo 2 > /proc/touchpanel/debug_level
    fi
}

#Fangfang.Hui@TECH.AD.Stability, 2019/08/13, Add for the quality feedback dcs config
function backupMinidump() {
    tag=`getprop sys.backup.minidump.tag`
    if [ x"$tag" = x"" ]; then
        echo "backup.minidump.tag is null, do nothing"
        return
    fi
    minidumppath="/data/oppo/log/DCS/de/AEE_DB"
    miniDumpFile=$minidumppath/$(ls -t ${minidumppath} | head -1)
    if [ x"$miniDumpFile" = x"" ]; then
        echo "minidump.file is null, do nothing"
        return
    fi
    result=$(echo $miniDumpFile | grep "${tag}")
    if [ x"$result" = x"" ]; then
        echo "tag mismatch, do not backup"
        return
    else
        try_copy_minidump_to_opporeserve $miniDumpFile
        setprop sys.backup.minidump.tag ""
    fi
}

function try_copy_minidump_to_opporeserve() {
    OPPORESERVE_MINIDUMP_BACKUP_PATH="/data/oppo/log/opporeserve/media/log/minidumpbackup"
    OPPORESERVE2_MOUNT_POINT="/mnt/vendor/opporeserve"

    if [ ! -d ${OPPORESERVE_MINIDUMP_BACKUP_PATH} ]; then
        mkdir ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
    fi
    #chmod -R 0774 ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
    #chown -R system ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
    #chgrp -R system ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
    NewLogPath=$1
    if [ ! -f $NewLogPath ] ;then
        echo "Can not access ${NewLogPath}, the file may not exists "
        return
    fi
    TmpLogSize=$(du -sk ${NewLogPath} | sed 's/[[:space:]]/,/g' | cut -d "," -f1) #`du -s -k ${NewLogPath} | $XKIT awk '{print $1}'`
    curBakCount=`ls ${OPPORESERVE_MINIDUMP_BACKUP_PATH} | wc -l`
    echo "curBakCount = ${curBakCount}, TmpLogSize = ${TmpLogSize}, NewLogPath = ${NewLogPath}"
    while [ ${curBakCount} -gt 5 ]   #can only save 5 backup minidump logs at most
    do
        rm -rf ${OPPORESERVE_MINIDUMP_BACKUP_PATH}/$(ls -t ${OPPORESERVE_MINIDUMP_BACKUP_PATH} | tail -1)
        curBakCount=`ls ${OPPORESERVE_MINIDUMP_BACKUP_PATH} | wc -l`
        echo "delete one file curBakCount = $curBakCount"
    done
    FreeSize=$(df -ak | grep "${OPPORESERVE_MINIDUMP_BACKUP_PATH}" | sed 's/[ ][ ]*/,/g' | cut -d "," -f4)
    TotalSize=$(df -ak | grep "${OPPORESERVE_MINIDUMP_BACKUP_PATH}" | sed 's/[ ][ ]*/,/g' | cut -d "," -f2)
    ReserveSize=`expr $TotalSize / 5`
    NeedSize=`expr $TmpLogSize + $ReserveSize`
    echo "NeedSize = ${NeedSize}, ReserveSize = ${ReserveSize}, FreeSize = ${FreeSize}"
    while [ ${FreeSize} -le ${NeedSize} ]
    do
        curBakCount=`ls ${OPPORESERVE_MINIDUMP_BACKUP_PATH} | wc -l`
        if [ $curBakCount -gt 1 ]; then #leave at most on log file
            rm -rf ${OPPORESERVE_MINIDUMP_BACKUP_PATH}/$(ls -t ${OPPORESERVE_MINIDUMP_BACKUP_PATH} | tail -1)
            echo "${OPPORESERVE2_MOUNT_POINT} left space ${FreeSize} not enough for minidump, delete one de minidump"
            FreeSize=$(df -k | grep "${OPPORESERVE2_MOUNT_POINT}" | sed 's/[ ][ ]*/,/g' | cut -d "," -f4)
            continue
        fi
        echo "${OPPORESERVE2_MOUNT_POINT} left space ${FreeSize} not enough for minidump, nothing to delete"
        return 0
    done
    #space is enough, now copy
    cp $NewLogPath $OPPORESERVE_MINIDUMP_BACKUP_PATH
    chmod -R 0771 ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
    chown -R system ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
    chgrp -R system ${OPPORESERVE_MINIDUMP_BACKUP_PATH}
}

#Jianping.Zheng 2017/06/20, Add for collect futexwait block log
function collect_futexwait_log() {
    collect_path=/data/system/dropbox/extra_log
    if [ ! -d ${collect_path} ]
    then
        mkdir -p ${collect_path}
        chmod 700 ${collect_path}
        chown system:system ${collect_path}
    fi

    #time
    echo `date` > ${collect_path}/futexwait.time.txt

    #ps -t info
    ps -A -T > $collect_path/ps.txt

    #D status to dmesg
    echo w > /proc/sysrq-trigger

    #systemserver trace
    system_server_pid=`ps -A |grep system_server | $XKIT awk '{print $2}'`
    kill -3 ${system_server_pid}
    sleep 10
    cp /data/anr/traces.txt $collect_path/

    #systemserver native backtrace
    debuggerd -b ${system_server_pid} > $collect_path/systemserver.backtrace.txt
}

#Jianping.Zheng 2017/05/08, Add for systemserver futex_wait block check
function checkfutexwait_wrap() {
    if [ -f /system/bin/checkfutexwait ]; then
        setprop ctl.start checkfutexwait_bin
    else
        while [ true ];do
            is_futexwait_started=`getprop init.svc.checkfutexwait`
            if [ x"${is_futexwait_started}" != x"running" ]; then
                setprop ctl.start checkfutexwait
            fi
            sleep 180
        done
    fi
}

function do_check_systemserver_futexwait_block() {
    exception_max=`getprop persist.sys.futexblock.max`
    if [ x"${exception_max}" = x"" ]; then
        exception_max=60
    fi

    system_server_pid=`ps -A |grep system_server | $XKIT awk '{print $2}'`
    if [ x"${system_server_pid}" != x"" ]; then
        exception_count=0
        while [ $exception_count -lt $exception_max ] ;do
            systemserver_stack_status=`ps -A | grep system_server | $XKIT awk '{print $6}'`
            if [ x"${systemserver_stack_status}" != x"futex_wait_queue_me" ]; then
                break
            fi

            inputreader_stack_status=`ps -A -T | grep InputReader  | $XKIT awk '{print $7}'`
            if [ x"${inputreader_stack_status}" == x"futex_wait_queue_me" ]; then
                exception_count=`expr $exception_count + 1`
                if [ x"${exception_count}" = x"${exception_max}" ]; then
                    echo "Systemserver,FutexwaitBlocked-"`date` > "/proc/sys/kernel/hung_task_kill"
                    setprop sys.oppo.futexwaitblocked "`date`"
                    collect_futexwait_log
                    kill -9 $system_server_pid
                    sleep 60
                    break
                fi
                sleep 1
            else
                break
            fi
        done
    fi
}
#end, add for systemserver futex_wait block check

# Add for clean pcm dump file.
function cleanpcmdump() {
    rm -rf /data/vendor/audiohal/audio_dump/*
    rm -rf /data/vendor/audiohal/aurisys_dump/*
    rm -rf /data/debuglogger/audio_dump/*
    rm -rf /sdcard/mtklog/audio_dump/*
}

#Jianping.Zheng 2017/06/12, Add for record d status thread stack
function record_d_threads_stack() {
    record_path=$1
    echo "\ndate->" `date` >> ${record_path}
    ignore_threads="kworker/u16:1|mdss_dsi_event|mmc-cmdqd/0|msm-core:sampli|kworker/10:0|mdss_fb0\
|mts_thread|fuse_log|ddp_irq_log_kth|disp_check|decouple_trigge|ccci_fsm1|ccci_poll1|hang_detect\
|gauge_coulomb_t|battery_thread|power_misc_thre|gauge_timer_thr|ipi_cpu_dvfs_rt|smart_det|charger_thread"
    d_status_tids=`ps -t | grep " D " | grep -iEv "$ignore_threads" | $XKIT awk '{print $2}'`;
    if [ x"${d_status_tids}" != x"" ]
    then
        sleep 5
        d_status_tids_again=`ps -t | grep " D " | grep -iEv "$ignore_threads" | $XKIT awk '{print $2}'`;
        for tid in ${d_status_tids}
        do
            for tid_2 in ${d_status_tids_again}
            do
                if [ x"${tid}" == x"${tid_2}" ]
                then
                    thread_stat=`cat /proc/${tid}/stat | grep " D "`
                    if [ x"${thread_stat}" != x"" ]
                    then
                        echo "tid:"${tid} "comm:"`cat /proc/${tid}/comm` "cmdline:"`cat /proc/${tid}/cmdline`  >> ${record_path}
                        echo "stack:" >> ${record_path}
                        cat /proc/${tid}/stack >> ${record_path}
                    fi
                    break
                fi
            done
        done
    fi
}

#Jianping.Zheng, 2017/04/04, Add for record performance
function perf_record() {
    check_interval=`getprop persist.sys.oppo.perfinteval`
    if [ x"${check_interval}" = x"" ]; then
        check_interval=60
    fi
    perf_record_path=/data/oppo_log/perf_record_logs
    while [ true ];do
        if [ ! -d ${perf_record_path} ];then
            mkdir -p ${perf_record_path}
        fi

        echo "\ndate->" `date` >> ${perf_record_path}/cpu.txt
        cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq >> ${perf_record_path}/cpu.txt

        echo "\ndate->" `date` >> ${perf_record_path}/mem.txt
        cat /proc/meminfo >> ${perf_record_path}/mem.txt

        echo "\ndate->" `date` >> ${perf_record_path}/buddyinfo.txt
        cat /proc/buddyinfo >> ${perf_record_path}/buddyinfo.txt

        echo "\ndate->" `date` >> ${perf_record_path}/top.txt
        top -n 1 -H >> ${perf_record_path}/top.txt

        #record_d_threads_stack "${perf_record_path}/d_status.txt"

        sleep "$check_interval"
    done
}

function powerlog() {
    pmlog=data/system/powermonitor_backup/
    if [ -d "$pmlog" ]; then
        mkdir -p sdcard/mtklog/powermonitor_backup
        cp -r data/system/powermonitor_backup/* sdcard/mtklog/powermonitor_backup/
    fi
}

# Add for logkit2.0 clean log command
function cleanlog() {
    rm -rf /sdcard/mtklog/
    rm -rf /data/debuglogger/
    rm -rf /sdcard/debuglogger/
    rm -rf /sdcard/oppo_log/
    rm -rf /data/vendor/audiohal/audio_dump/*
    rm -rf /data/vendor/audiohal/aurisys_dump/*
}

function clearDataDebugLog(){
    MTK_DEBUG_PATH=/data/debuglogger
    if [ -d ${DATA_LOG_PATH} ]; then
        chmod 777 -R ${DATA_LOG_PATH}
        rm -rf ${DATA_LOG_PATH}/*
    fi
    if [ -d ${MTK_DEBUG_PATH} ]; then
        rm -rf ${MTK_DEBUG_PATH}/*
    fi
    setprop sys.clear.finished 1
}

function screen_record_backup(){
    backupFile="${SDCARD_LOG_BASE_PATH}/screen_record/screen_record_old.mp4"
    if [ -f "$backupFile" ]; then
         rm $backupFile
    fi

    curFile="${SDCARD_LOG_BASE_PATH}/screen_record/screen_record.mp4"
    if [ -f "$curFile" ]; then
         mv $curFile $backupFile
    fi
}

function pwkdumpon(){
    echo 1 >  /proc/aee_kpd_enable
}

function pwkdumpoff(){
    echo 0 >  /proc/aee_kpd_enable
}

# Add for full dump & mini dump
function mrdumpon(){
#zhouhengguo@BSP.Kernel.Stablity, 2019/10/22, remove ext4 param for fulldump
#    mrdump_tool output-set internal-storage:ext4
    mrdump_tool output-set internal-storage
}

function mrdumpoff(){
    mrdump_tool output-set none
}

function testTransferSystem(){
    TMPTIME=`date +%F-%H-%M-%S`
    setprop sys.oppo.log.stoptime ${TMPTIME}
    stoptime=`getprop sys.oppo.log.stoptime`;
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    echo "${newpath}"

    mkdir -p ${newpath}/system
    #tar -cvf ${newpath}/log.tar data/oppo/log/*
    cp -rf /data/oppo/log/ ${newpath}/system
}

function testTransferRoot(){
    TMPTIME=`date +%F-%H-%M-%S`
    setprop sys.oppo.log.stoptime ${TMPTIME}
    stoptime=`getprop sys.oppo.log.stoptime`;
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    echo "${newpath}"

    mkdir -p ${newpath}
    mv /data/debuglogger ${newpath}
}

function checkSizeAndCopy(){
    LOG_SOURCE_PATH="$1"
    LOG_TARGET_PATH="$2"
    echo "${CURTIME_FORMAT} CHECKSIZEANDCOPY:from ${LOG_SOURCE_PATH} to ${LOG_TARGET_PATH}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    LIMIT_SIZE="10240"

    if [ -d "${LOG_SOURCE_PATH}" ]; then
        TMP_LOG_SIZE=`du -s -k ${LOG_SOURCE_PATH} | awk '{print $1}'`
        if [ ${TMP_LOG_SIZE} -le ${LIMIT_SIZE} ]; then  #log size less then 10M
            mkdir -p ${newpath}/${LOG_TARGET_PATH}
            cp -rf ${LOG_SOURCE_PATH}/* ${newpath}/${LOG_TARGET_PATH}
            echo "${CURTIME_FORMAT} CHECKSIZEANDCOPY:${LOG_SOURCE_PATH} done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        else
            echo "${CURTIME_FORMAT} CHECKSIZEANDCOPY:${LOG_SOURCE_PATH} SIZE:${TMP_LOG_SIZE}/${LIMIT_SIZE}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        fi
    fi
}

function checkNumberAndCopy(){
    LOG_SOURCE_PATH="$1"
    LOG_TARGET_PATH="$2"
    echo "${CURTIME_FORMAT} CHECKNUMBERANDCOPY:from ${LOG_SOURCE_PATH} to ${LOG_TARGET_PATH}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    LIMIT_NUM=1000

    if [ -d "${LOG_SOURCE_PATH}" ] && [ ! "`ls -A ${LOG_SOURCE_PATH}`" = "" ]; then
        TMP_LOG_NUM=`ls -lR ${LOG_SOURCE_PATH} |grep "^-"|wc -l | awk '{print $1}'`
        echo "${CURTIME_FORMAT} checkNumber and copy:${LOG_SOURCE_PATH} ${TMP_LOG_NUM}/${LIMIT_NUM}"
        if [ ${TMP_LOG_NUM} -le ${LIMIT_NUM} ]; then  #log number less then 1000
            if [ ! -d ${LOG_TARGET_PATH} ];then
                mkdir -p ${LOG_TARGET_PATH}
            fi

            cp -rf ${LOG_SOURCE_PATH}/* ${LOG_TARGET_PATH}
            echo "${CURTIME_FORMAT} CHECKNUMBERANDCOPY:${LOG_SOURCE_PATH} done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        else
            echo "${CURTIME_FORMAT} CHECKNUMBERANDCOPY:${LOG_SOURCE_PATH} NUM:${TMP_LOG_NUM}/${LIMIT_NUM}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        fi
    fi
}

function checkNumberAndMove(){
    LOG_SOURCE_PATH="$1"
    LOG_TARGET_PATH="$2"
    echo "${CURTIME_FORMAT} CHECKNUMBERANDMOVE:from ${LOG_SOURCE_PATH} to ${LOG_TARGET_PATH}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    LIMIT_NUM=2000

    if [ -d "${LOG_SOURCE_PATH}" ] && [ ! "`ls -A ${LOG_SOURCE_PATH}`" = "" ]; then
        TMP_LOG_NUM=`ls -lR ${LOG_SOURCE_PATH} |grep "^-"|wc -l | awk '{print $1}'`
        echo "${CURTIME_FORMAT} CHECKNUMBERANDMOVE:${LOG_SOURCE_PATH} ${TMP_LOG_NUM}/${LIMIT_NUM}"
        if [ ${TMP_LOG_NUM} -le ${LIMIT_NUM} ]; then  #log number less then 1000
            if [ ! -d ${LOG_TARGET_PATH} ];then
                mkdir -p ${LOG_TARGET_PATH}
            fi

            mv ${LOG_SOURCE_PATH}/* ${LOG_TARGET_PATH}
            echo "${CURTIME_FORMAT} CHECKNUMBERANDMOVE:${LOG_SOURCE_PATH} done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        else
            echo "${CURTIME_FORMAT} CHECKNUMBERANDMOVE:${LOG_SOURCE_PATH} NUM:${TMP_LOG_NUM}/${LIMIT_NUM}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        fi
    fi
}

function checkFileAndMove(){
    LOG_SOURCE_PATH="$1"
    LOG_TARGET_PATH="$2"
    echo "${CURTIME_FORMAT} checkFileAndMove:from ${LOG_SOURCE_PATH} to ${LOG_TARGET_PATH}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log

    if [ -f "${LOG_SOURCE_PATH}" ]; then
        mv ${LOG_SOURCE_PATH} ${LOG_TARGET_PATH}
        rm ${LOG_SOURCE_PATH}
        echo "${CURTIME_FORMAT} checkFileAndMove:mv ${LOG_SOURCE_PATH} to ${LOG_TARGET_PATH} done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    else
        echo "checkFileAndMove: ${LOG_SOURCE_PATH} is not a original File"
    fi
}

function checkNumberSizeAndCopy(){
    LOG_SOURCE_PATH="$1"
    LOG_TARGET_PATH="$2"
    LOG_LIMIT_NUM="$3"
    LOG_LIMIT_SIZE="$4"
    echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDCOPY:FROM ${LOG_SOURCE_PATH} TO ${LOG_TARGET_PATH}"
    LIMIT_NUM=1000
    #500*1024MB
    LIMIT_SIZE="512000"

    if [ -d "${LOG_SOURCE_PATH}" ] && [ ! "`ls -A ${LOG_SOURCE_PATH}`" = "" ]; then
        TMP_LOG_NUM=`ls -lR ${LOG_SOURCE_PATH} |grep "^-"|wc -l | awk '{print $1}'`
        TMP_LOG_SIZE=`du -s -k ${LOG_SOURCE_PATH} | awk '{print $1}'`
        echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDCOPY:NUM:${TMP_LOG_NUM}/${LIMIT_NUM} SIZE:${TMP_LOG_SIZE}/${LIMIT_SIZE}"
        if [ ${TMP_LOG_NUM} -le ${LIMIT_NUM} ] && [ ${TMP_LOG_SIZE} -le ${LIMIT_SIZE} ]; then
            if [ ! -d ${LOG_TARGET_PATH} ];then
                mkdir -p ${LOG_TARGET_PATH}
            fi

            cp -rf ${LOG_SOURCE_PATH}/* ${LOG_TARGET_PATH}
            echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDCOPY:${LOG_SOURCE_PATH} done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        else
            echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDCOPY:${LOG_SOURCE_PATH} NUM:${TMP_LOG_NUM}/${LIMIT_NUM} SIZE:${TMP_LOG_SIZE}/${LIMIT_SIZE}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
            rm -f ${LOG_SOURCE_PATH}/*
        fi
    fi
}

function checkNumberSizeAndMove(){
    LOG_SOURCE_PATH="$1"
    LOG_TARGET_PATH="$2"
    LOG_LIMIT_NUM="$3"
    LOG_LIMIT_SIZE="$4"
    echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDMOVE:FROM ${LOG_SOURCE_PATH} TO ${LOG_TARGET_PATH}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    LIMIT_NUM=1000
    #500*1024KB
    LIMIT_SIZE="512000"

    if [ -d "${LOG_SOURCE_PATH}" ] && [ ! "`ls -A ${LOG_SOURCE_PATH}`" = "" ]; then
        TMP_LOG_NUM=`ls -lR ${LOG_SOURCE_PATH} |grep "^-"|wc -l | awk '{print $1}'`
        TMP_LOG_SIZE=`du -s -k ${LOG_SOURCE_PATH} | awk '{print $1}'`
        echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDMOVE:NUM:${TMP_LOG_NUM}/${LIMIT_NUM} SIZE:${TMP_LOG_SIZE}/${LIMIT_SIZE}"
        if [ ${TMP_LOG_NUM} -le ${LIMIT_NUM} ] && [ ${TMP_LOG_SIZE} -le ${LIMIT_SIZE} ]; then
            if [ ! -d ${LOG_TARGET_PATH} ];then
                mkdir -p ${LOG_TARGET_PATH}
            fi

            mv ${LOG_SOURCE_PATH}/* ${LOG_TARGET_PATH}
            echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDMOVE:${LOG_SOURCE_PATH} done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        else
            echo "${CURTIME_FORMAT} CHECKNUMBERSIZEANDMOVE:${LOG_SOURCE_PATH} NUM:${TMP_LOG_NUM}/${LIMIT_NUM} SIZE:${TMP_LOG_SIZE}/${LIMIT_SIZE}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
            rm -f ${LOG_SOURCE_PATH}/*
        fi
    fi
}

function transferSystrace(){
    SYSTRACE_LOG=/data/local/traces
    TARGET_SYSTRACE_LOG=${newpath}/systrace

    checkNumberSizeAndMove ${SYSTRACE_LOG} ${TARGET_SYSTRACE_LOG}
}

function transferScreenshots() {
    MAX_NUM=5
    is_release=`getprop ro.build.release_type`
    if [ x"${is_release}" != x"true" ]; then
        #Zhiming.chen@ANDROID.DEBUG.BugID 2724830, 2019/12/17,The log tool captures child user screenshots
        ALL_USER=`ls -t data/media/`
        for m in $ALL_USER;
        do
            IDX=0
            screen_shot="/data/media/$m/DCIM/Screenshots/"
            if [ -d "$screen_shot" ]; then
                mkdir -p ${newpath}/Screenshots/$m
                touch ${newpath}/Screenshots/$m/.nomedia
                ALL_FILE=`ls -t $screen_shot`
                for i in $ALL_FILE;
                do
                    echo "now we have file $i"
                    let IDX=$IDX+1;
                    echo ========file num is $IDX===========
                    if [ "$IDX" -lt $MAX_NUM ] ; then
                       echo  $i\!;
                       cp $screen_shot/$i ${newpath}/Screenshots/$m/
                    fi
                done
            fi
        done
    fi
    echo "${CURTIME_FORMAT} SCREENSHOTS:copy screenshots done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
}

function transferFingerprint() {
    checkNumberAndMove "/data/vendor_de/0/faceunlock" "${newpath}/faceunlock"

    FINGERPRINT_LOG=${newpath}/fingerprint
    checkNumberAndCopy "/persist/silead" "${FINGERPRINT_LOG}"
    checkNumberAndMove "/data/system/silead" "${FINGERPRINT_LOG}"
    checkNumberAndMove "/data/vendor/silead" "${FINGERPRINT_LOG}"
    checkNumberAndMove "/data/vendor/optical_fingerprint" "${FINGERPRINT_LOG}"
    checkNumberAndMove "/data/vendor/fingerprint" "${FINGERPRINT_LOG}"
}

function transferTouchpanel() {
    echo "transferTouchpanel executing" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    checkFileAndMove "/sdcard/tp_debug_info.txt" "${newpath}/tp_debug_info.txt"
}

function copyWeixinXlog() {
    stoptime=`getprop sys.oppo.log.stoptime`;
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    saveallxlog=`getprop sys.oppo.log.save_all_xlog`
    argtrue='true'
    XLOG_MAX_NUM=35
    XLOG_IDX=0
    XLOG_DIR="/sdcard/Android/data/com.tencent.mm/MicroMsg/xlog"
    CRASH_DIR="/sdcard/Android/data/com.tencent.mm/MicroMsg/crash"
    mkdir -p ${newpath}/wechatlog
    if [ "${saveallxlog}" = "${argtrue}" ]; then
        mkdir -p ${newpath}/wechatlog/xlog
        if [ -d "${XLOG_DIR}" ]; then
            cp -rf ${XLOG_DIR}/*.xlog ${newpath}/wechatlog/xlog/
        fi
    else
        if [ -d "${XLOG_DIR}" ]; then
            mkdir -p ${newpath}/wechatlog/xlog
            ALL_FILE=`find ${XLOG_DIR} -iname '*.xlog' | xargs ls -t`
            for i in $ALL_FILE;
            do
                echo "now we have Xlog file $i"
                let XLOG_IDX=$XLOG_IDX+1;
                echo ========file num is $XLOG_IDX===========
                if [ "$XLOG_IDX" -lt $XLOG_MAX_NUM ] ; then
                    #echo  $i >> ${newpath}/xlog/.xlog.txt
                    cp $i ${newpath}/wechatlog/xlog/
                fi
            done
        fi
    fi
    setprop sys.tranfer.finished cp:xlog
    mkdir -p ${newpath}/wechatlog/crash
    if [ -d "${CRASH_DIR}" ]; then
            cp -rf ${CRASH_DIR}/* ${newpath}/wechatlog/crash/
    fi

    XLOG_IDX=0
    if [ "${saveallxlog}" = "${argtrue}" ]; then
        mkdir -p ${newpath}/sub_wechatlog/xlog
        cp -rf /storage/ace-999/Android/data/com.tencent.mm/MicroMsg/xlog/* ${newpath}/sub_wechatlog/xlog
    else
        if [ -d "/storage/ace-999/Android/data/com.tencent.mm/MicroMsg/xlog" ]; then
            mkdir -p ${newpath}/sub_wechatlog/xlog
            ALL_FILE=`ls -t /storage/ace-999/Android/data/com.tencent.mm/MicroMsg/xlog`
            for i in $ALL_FILE;
            do
                echo "now we have subXlog file $i"
                let XLOG_IDX=$XLOG_IDX+1;
                echo ========file num is $XLOG_IDX===========
                if [ "$XLOG_IDX" -lt $XLOG_MAX_NUM ] ; then
                   echo  $i\!;
                    cp  /storage/ace-999/Android/data/com.tencent.mm/MicroMsg/xlog/$i ${newpath}/sub_wechatlog/xlog
                fi
            done
        fi
    fi
    setprop sys.tranfer.finished cp:sub_wechatlog
}

function copyQQlog() {
    stoptime=`getprop sys.oppo.log.stoptime`;
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    saveallqqlog=`getprop sys.oppo.log.save_all_qqlog`
    argtrue='true'
    QQLOG_MAX_NUM=100
    QQLOG_IDX=0
    QQLOG_DIR="/sdcard/Tencent/msflogs/com/tencent/mobileqq"
    mkdir -p ${newpath}/qqlog
    if [ -d "${QQLOG_DIR}" ]; then
        mkdir -p ${newpath}/qqlog
        QQ_FILE=`find ${QQLOG_DIR} -iname '*log' | xargs ls -t`
        for i in $QQ_FILE;
        do
            echo "now we have QQlog file $i"
            let QQLOG_IDX=$QQLOG_IDX+1;
            echo ========file num is $QQLOG_IDX===========
            if [ "$QQLOG_IDX" -lt $QQLOG_MAX_NUM ] ; then
                cp $i ${newpath}/qqlog
            fi
        done
    fi
    setprop sys.tranfer.finished cp:qqlog

    QQLOG_IDX=0
    if [ -d "/storage/ace-999/Tencent/msflogs/com/tencent/mobileqq" ]; then
        mkdir -p ${newpath}/sub_qqlog
        ALL_FILE=`ls -t /storage/ace-999/Tencent/msflogs/com/tencent/mobileqq`
        for i in $ALL_FILE;
        do
            echo "now we have subQQlog file $i"
            let QQLOG_IDX=$QQLOG_IDX+1;
            echo ========file num is $QQLOG_IDX===========
            if [ "$QQLOG_IDX" -lt $QQLOG_MAX_NUM ] ; then
               echo  $i\!;
                cp  /storage/ace-999/Tencent/msflogs/com/tencent/mobileqq/$i ${newpath}/sub_qqlog
            fi
        done
    fi
    setprop sys.tranfer.finished cp:sub_qqlog
}

function transferPower() {
    dumpsys batterystats --thermalrec
    thermalstats_file="/data/system/thermalstats.bin"
    if [ -f ${thermalstats_file} ] ; then
        mkdir -p ${newpath}/power/thermalrec/
        chmod 770 ${thermalstats_file}
	    cp -rf ${thermalstats_file} ${newpath}/power/thermalrec/
    fi

    thermalrec_dir="/data/system/thermal/dcs"
	chmod 770 /data/system/thermal/ -R
    checkNumberSizeAndCopy ${thermalrec_dir}/* ${newpath}/power/thermalrec/

    powermonitor_dir="/data/oppo/psw/powermonitor"
    if [ -d ${powermonitor_dir} ]; then
        echo "copy Powermonitor..." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        mkdir -p ${newpath}/power/powermonitor/
	    chmod 770 ${powermonitor_dir} -R
        cp -rf ${powermonitor_dir}/* ${newpath}/power/powermonitor/
    fi

    POWERMONITOR_BACKUP_LOG=/data/oppo/psw/powermonitor_backup/
    chmod 770 ${POWERMONITOR_BACKUP_LOG} -R
    if [ -d "${POWERMONITOR_BACKUP_LOG}" ]; then
        echo "copy powermonitor_backup..." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        mkdir -p ${newpath}/powermonitor_backup
        cp -rf ${POWERMONITOR_BACKUP_LOG}/* ${newpath}/powermonitor_backup/
    fi
    echo "${CURTIME_FORMAT} POWER:copy power done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
}

function transferThirdApp() {
    #Chunbo.Gao@ANDROID.DEBUG.NA, 2019/6/21, Add for tencent.ig
    tencent_pubgmhd_dir="/sdcard/Android/data/com.tencent.tmgp.pubgmhd/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs"
    if [ -d ${tencent_pubgmhd_dir} ]; then
        mkdir -p ${newpath}/os/Tencentlogs/pubgmhd
        echo "copy tencent.pubgmhd..."
        cp -rf ${tencent_pubgmhd_dir} ${newpath}/os/Tencentlogs/pubgmhd
    fi

    echo "${CURTIME_FORMAT} THIRDAPP:copy thirdapp done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
}

function transferColorOS(){
    #TraceLog
    TRACELOG=/sdcard/Documents/TraceLog
    checkSizeAndCopy "${TRACELOG}" "os/TraceLog"

    #assistantscreen
    ASSISTANTSCREEN_LOG=/sdcard/Download/AppmonitorSDKLogs/com.coloros.assistantscreen
    checkSizeAndCopy "${ASSISTANTSCREEN_LOG}" "os/Assistantscreen"

    #ovoicemanager
    OVOICEMANAGER_LOG=/data/data/com.oppo.ovoicemanager/files/ovmsAudio
    checkSizeAndCopy "${OVOICEMANAGER_LOG}" "os/Ovoicemanager"

    #OVMS
    OVMS_LOG=/sdcard/Documents/OVMS
    checkSizeAndCopy "${OVMS_LOG}" "os/OVMS"

    #Pictorial
    PICTORIAL_LOG=/sdcard/Android/data/com.heytap.pictorial/files/xlog
    checkSizeAndCopy "${PICTORIAL_LOG}" "os/Pictorial"

    #Camera
    CAMERA_LOG=/sdcard/DCIM/Camera/spdebug
    checkSizeAndCopy "${CAMERA_LOG}" "os/Camera"

    #Browser
    BROWSER_LOG=/sdcard/Android/data/com.heytap.browser/files/xlog
    checkSizeAndCopy "${BROWSER_LOG}" "os/com.heytap.browser"

    #MIDAS
    MIDAS_LOG=/sdcard/Android/data/com.oplus.onetrace/files/xlog
    checkSizeAndCopy "${MIDAS_LOG}" "os/com.oplus.onetrace"

    #common path
    cp -rf /sdcard/Documents/*/.dog/* ${newpath}/os/
    echo "${CURTIME_FORMAT} COLOROS:copy coloros done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
}

function transferUser() {
    stoptime=`getprop sys.oppo.log.stoptime`;
    userpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"

    USER_LOG=/data/system/users/0/*
    TARGET_USER_LOG=${userpath}/user_0
    mkdir -p ${TARGET_USER_LOG}
    touch ${TARGET_USER_LOG}/.nomedia
    checkNumberSizeAndCopy ${USER_LOG} ${TARGET_USER_LOG}

    wait
}

function transferRealTimeLog() {
    mv /data/debuglogger/ ${newpath}
    mv /sdcard/debuglogger ${newpath}

    #mv data/oppo_log/
    mkdir -p ${newpath}/data_oppolog
    mv /data/oppo_log/* ${newpath}/data_oppolog
}

function transferDataOppoLog(){
    DATA_OPLUS_LOG=/data/oppo/log
    TARGET_DATA_OPLUS_LOG=${newpath}/log

    chmod 777 ${DATA_OPLUS_LOG}/ -R
    #tar -czvf ${newpath}/LOG.dat.gz -C /data/oppo/log .
    #tar -czvf ${TARGET_DATA_OPLUS_LOG}/LOG.tar.gz ${DATA_OPLUS_LOG}

    # filter DCS
    if [ -d  ${DATA_OPLUS_LOG} ]; then
        ALL_SUB_DIR=`ls ${DATA_OPLUS_LOG} | grep -v DCS | grep -v data_vendor`
        for SUB_DIR in ${ALL_SUB_DIR};do
            if [ -d ${DATA_OPLUS_LOG}/${SUB_DIR} ] || [ -f ${DATA_OPLUS_LOG}/${SUB_DIR} ]; then
                checkNumberSizeAndCopy "${DATA_OPLUS_LOG}/${SUB_DIR}" "${TARGET_DATA_OPLUS_LOG}/${SUB_DIR}"
            fi
        done
    fi

    transferDataDCS
}

function transferDataDCS(){
    DATA_DCS_LOG=/data/oppo/log/DCS/de
    TARGET_DATA_DCS_LOG=${newpath}/log/DCS

    if [ -d  ${DATA_DCS_LOG} ]; then
        ALL_SUB_DIR=`ls ${DATA_DCS_LOG}`
        for SUB_DIR in ${ALL_SUB_DIR};do
            if [ -d ${DATA_DCS_LOG}/${SUB_DIR} ] || [ -f ${DATA_DCS_LOG}/${SUB_DIR} ]; then
                checkNumberSizeAndCopy "${DATA_DCS_LOG}/${SUB_DIR}" "${TARGET_DATA_DCS_LOG}/${SUB_DIR}"
            fi
        done
    fi

    DATA_DCS_OTRTA_LOG=/data/persist_log/backup
    if [ -d  ${DATA_DCS_LOG} ]; then
        ALL_SUB_DIR=`ls ${DATA_DCS_OTRTA_LOG}`
        for SUB_DIR in ${ALL_SUB_DIR};do
            if [ -d ${DATA_DCS_OTRTA_LOG}/${SUB_DIR} ] || [ -f ${DATA_DCS_OTRTA_LOG}/${SUB_DIR} ]; then
                checkNumberSizeAndCopy "${DATA_DCS_OTRTA_LOG}/${SUB_DIR}" "${TARGET_DATA_DCS_LOG}/${SUB_DIR}"
            fi
        done
    fi
}

function transferDataVendor(){
    stoptime=`getprop sys.oppo.log.stoptime`;
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    DATA_VENDOR_LOG=/data/oppo/log/data_vendor
    TARGET_DATA_VENDOR_LOG=${newpath}/data_vendor

    if [ -d  ${DATA_VENDOR_LOG} ]; then
        chmod 770 ${DATA_VENDOR_LOG}/ -R
        ALL_SUB_DIR=`ls ${DATA_VENDOR_LOG}`
        for SUB_DIR in ${ALL_SUB_DIR};do
            if [ -d ${DATA_VENDOR_LOG}/${SUB_DIR} ] || [ -f ${DATA_VENDOR_LOG}/${SUB_DIR} ]; then
                checkNumberSizeAndMove "${DATA_VENDOR_LOG}/${SUB_DIR}" "${TARGET_DATA_VENDOR_LOG}/${SUB_DIR}"
            fi
        done
    fi
}

function getSystemStatus() {
    echo "${CURTIME_FORMAT} GETSYSTEMSTATUS:start...." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    stoptime=`getprop sys.oppo.log.stoptime`;
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    SYSTEM_STATUS_PATH=${newpath}/SI_stop
    if [[ ! -d ${SYSTEM_STATUS_PATH} ]];then
        mkdir -p ${SYSTEM_STATUS_PATH}
    fi
    rm -f ${SYSTEM_STATUS_PATH}/finish_system
    echo "${CURTIME_FORMAT} GETSYSTEMSTATUS:${SYSTEM_STATUS_PATH}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log

    echo "${CURTIME_FORMAT} GETSYSTEMSTATUS:ps,top" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    ps -A -T > ${SYSTEM_STATUS_PATH}/ps.txt
    top -n 1 > ${SYSTEM_STATUS_PATH}/top.txt
    cat /proc/meminfo > ${SYSTEM_STATUS_PATH}/proc_meminfo.txt

    getprop > ${SYSTEM_STATUS_PATH}/prop.txt
    df > ${SYSTEM_STATUS_PATH}/df.txt
    mount > ${SYSTEM_STATUS_PATH}/mount.txt
    cat /proc/meminfo > ${SYSTEM_STATUS_PATH}/proc_meminfo.txt
    cat /data/system/packages.xml  > ${SYSTEM_STATUS_PATH}/packages.txt
    cat /data/system/appops.xml  > ${SYSTEM_STATUS_PATH}/appops.xml
    dumpsys appops > ${SYSTEM_STATUS_PATH}/dumpsys_appops.xml
    cat /proc/zoneinfo > ${SYSTEM_STATUS_PATH}/zoneinfo.txt
    cat /proc/slabinfo > ${SYSTEM_STATUS_PATH}/slabinfo.txt
    cat /proc/interrupts > ${SYSTEM_STATUS_PATH}/interrupts.txt
    cat /sys/kernel/debug/wakeup_sources > ${SYSTEM_STATUS_PATH}/wakeup_sources.log
    cp -rf /sys/kernel/debug/ion ${SYSTEM_STATUS_PATH}/

    #dumpsys meminfo
    dumpsys -t 15 meminfo > ${SYSTEM_STATUS_PATH}/dumpsys_meminfo.txt &

    #dumpsys package
    traceTransferState "dumpSystem:package start"
    dumpsys package --da > ${SYSTEM_STATUS_PATH}/dumpsys_package_da.txt
    traceTransferState "dumpSystem:package end"

    dumpsys location > ${SYSTEM_STATUS_PATH}/dumpsys_location.txt
    dumpsys power > ${SYSTEM_STATUS_PATH}/dumpsys_power.txt
    dumpsys alarm > ${SYSTEM_STATUS_PATH}/dumpsys_alarm.txt
    dumpsys batterystats > ${SYSTEM_STATUS_PATH}/dumpsys_batterystats.txt
    dumpsys batterystats -c > ${SYSTEM_STATUS_PATH}/battersystats_for_bh.txt
    dumpsys activity exit-info > ${SYSTEM_STATUS_PATH}/dumpsys_exit_info.txt
    dumpsys dropbox --print > ${SYSTEM_STATUS_PATH}/dumpsys_dropbox_all.txt

    #yong8.huang@ANDROID.AMS, 2020/12/30, Add for dumpsys activity info
    dumpsys activity processes > ${SYSTEM_STATUS_PATH}/dumpsys_processes.txt
    dumpsys activity broadcasts > ${SYSTEM_STATUS_PATH}/dumpsys_broadcasts.txt
    dumpsys activity providers > ${SYSTEM_STATUS_PATH}/dumpsys_providers.txt
    dumpsys activity services > ${SYSTEM_STATUS_PATH}/dumpsys_services.txt

    ##kevin.li@ROM.Framework, 2019/11/5, add for hans freeze manager(for protection)
    hans_enable=`getprop persist.sys.enable.hans`
    if [ "$hans_enable" == "true" ]; then
        dumpsys activity hans history > ${SYSTEM_STATUS_PATH}/dumpsys_hans_history.txt
    fi
    #kevin.li@ROM.Framework, 2019/12/2, add for hans cts property
    hans_enable=`getprop persist.vendor.enable.hans`
    if [ "$hans_enable" == "true" ]; then
        dumpsys activity hans history > ${SYSTEM_STATUS_PATH}/dumpsys_hans_history.txt
    fi

    #chao.zhu@ROM.Framework, 2020/04/17, add for preload
    preload_enable=`getprop persist.vendor.enable.preload`
    if [ "$preload_enable" == "true" ]; then
        dumpsys activity preload > ${SYSTEM_STATUS_PATH}/dumpsys_preload.txt
    fi

    echo "${CURTIME_FORMAT} GETSYSTEMSTATUS:done...." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    wait
    touch ${SYSTEM_STATUS_PATH}/finish_system
}

#Wenshuai.Chen@RM.AD.OppoDebug.LogKit.NA, 2020/11/27, Add for bugreport log
function dump_bugreport() {
    traceTransferState "bugreport start..."
    if [ ! -d "${SDCARD_LOG_TRIGGER_PATH}" ];then
        mkdir -p ${SDCARD_LOG_TRIGGER_PATH}
    fi
    bugreport > ${SDCARD_LOG_TRIGGER_PATH}/bugreport_${CURTIME}.txt
}

function checkDumpSystemDone(){
    DUMP_SYSTEM_LOG=${newpath}/SI_stop

    count=0
    while [ $count -le 30 ] && [ ! -f ${DUMP_SYSTEM_LOG}/finish_system ];do
        echo "${CURTIME_FORMAT} ${LOGTAG}:count=$count" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
        count=$((count + 1))
        sleep 1
    done
}

function transferAnrTomb() {
    stoptime=`getprop sys.oppo.log.stoptime`;
    TMP_PATH="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    echo "${CURTIME_FORMAT} TRANSFERANRTOMB:start...." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log

    ANR_LOG=/data/anr
    TARGET_ANR_LOG=${TMP_PATH}/anr
    TOMBSTONE_LOG=/data/tombstones
    TARGET_TOMBSTONE_LOG=${TMP_PATH}/tombstones

    checkNumberSizeAndCopy "${ANR_LOG}" "${TARGET_ANR_LOG}"
    checkNumberSizeAndCopy "${TOMBSTONE_LOG}" "${TARGET_TOMBSTONE_LOG}"

    echo "${CURTIME_FORMAT} TRANSFERANRTOMB:done...." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    wait
}

function transferMtkLog() {
    LOGTAG="MTKLOG"
    setprop ctl.start dump_system
    setprop ctl.start transferUser

    stoptime=`getprop sys.oppo.log.stoptime`;
    echo "${CURTIME_FORMAT} ${LOGTAG}:start...." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    mkdir -p ${newpath}
    echo "${CURTIME_FORMAT} ${LOGTAG}:from ${DATA_LOG_PATH} to ${newpath}" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log

    transferRealTimeLog

    transferScreenshots

    #Yujie.long@PSW.AD.OppoLog, 2020/02/26, add for cp recovery logs
    mvrecoverylog

    transferFingerprint
    transferTouchpanel

    mv ${SDCARD_LOG_BASE_PATH}/recovery_log/ ${newpath}
    mv ${SDCARD_LOG_TRIGGER_PATH} ${newpath}/

    copyWeixinXlog
    echo "${CURTIME_FORMAT} transfer log:copy wechat Xlog done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    copyQQlog
    echo "${CURTIME_FORMAT} transfer log:copy qq log done" >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log

    #get  proc/delllog
    #cat /proc/dellog > ${newpath}/proc_dellog.txt

    transferPower
    transferThirdApp
    transferColorOS

    #cp dropbox traces tombstone
    chmod 777 -R /data/system/dropbox
    chmod 777 -R /data/anr
    chmod 777 -R /data/tombstones
    cp -rf /data/system/dropbox ${newpath}/
    #cp -rf /data/anr ${newpath}/
    #cp -rf /data/tombstones ${newpath}/
    #mkdir -p ${newpath}/tombstones/vendor
    #cp /data/vendor/tombstones/* ${newpath}/tombstones/vendor

    transferDataOppoLog

    # systrace
    transferSystrace

    ## cp aee_exp/
    mkdir -p ${newpath}/data_aee
    cp -rf /data/aee_exp/* ${newpath}/data_aee
    rm -rf /data/aee_exp/*
    #mkdir -p ${newpath}/vendor_aee
    #cp -rf /data/vendor/aee_exp/* ${newpath}/vendor_aee
    #rm -rf /data/vendor/aee_exp/*

    setprop ctl.start transfer_anrtomb
    checkDumpSystemDone

    #LongYujie@OPPO.DEBUG, 2020/06/29, add for cp vendor file
    #transfer_vendor_file

    wait
    setprop sys.tranfer.finished 1
    echo "${CURTIME_FORMAT} ${LOGTAG}:done...." >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    mv ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log ${newpath}/
}

#ifdef OPLUS_FEATURE_EAP
#Haifei.Liu@ANDROID.RESCONTROL, 2020/08/18, Add for copy binder_info
function copyEapBinderInfo() {
    destBinderInfoPath=`getprop sys.eap.binderinfo.path`
    echo ${destBinderInfoPath}
    cat /sys/kernel/debug/binder/state > ${destBinderInfoPath}
}
#endif /* OPLUS_FEATURE_EAP */

#ifdef OPLUS_FEATURE_LOGKIT
#LongYujie@OPPO.DEBUG, 2020/06/29, add for cp vendor file
function transfer_vendor_file(){
    MAX_TIMES=10
    wait_times=0
    transfer_vendor_file_completed=`getprop sys.tranfer_vendor_file.finished`
    while [ x${transfer_vendor_file_completed} != x"1" -a $wait_times -lt $MAX_TIMES ];do
        sleep 1s
        transfer_vendor_file_completed=`getprop sys.tranfer_vendor_file.finished`
        wait_times=$wait_times+1
    done
    if [ $wait_times -eq $MAX_TIMES ];then
        mkdir -p ${newpath}
        touch ${newpath}/warming.txt
        echo "transfer vendor file to temp : time out!" > ${newpath}/warming.txt
        return
    fi
    setprop sys.tranfer_vendor_file.finished 0

    chmod 777 -R data/oppo/log/vendor_temp

    # mv fingerprint logs
    mkdir -p ${newpath}/fingerprint
    mkdir -p ${newpath}/fingerprint/silead
    mkdir -p ${newpath}/fingerprint/gf_data
    mv /data/oppo/log/vendor_temp/fingerprint/silead/* ${newpath}/fingerprint/silead
    mv /data/oppo/log/vendor_temp/fingerprint/gf_data/* ${newpath}/fingerprint/gf_data
    # mv faceunlock logs
    mkdir -p ${newpath}/faceunlock
    mv /data/oppo/log/vendor_temp/faceunlock/* ${newpath}/faceunlock/

    # cp data/vendor/tombstones
    mkdir -p ${newpath}/vendor_tombstones
    cp -rf /data/oppo/log/vendor_temp/tombstones/* ${newpath}/vendor_tombstones

    # cp /data/vendor/audiohal/audio_dump/ and /data/vendor/audiohal/aurisys_dump/
    mkdir -p ${newpath}/audiohal/audio_dump
    mkdir -p ${newpath}/audiohal/aurisys_dump
    cp -rf /data/oppo/log/vendor_temp/audiohal/audio_dump/* ${newpath}/audiohal/audio_dump
    cp -rf /data/oppo/log/vendor_temp/audiohal/aurisys_dump/* ${newpath}/audiohal/aurisys_dump

    # cp /data/vendor/aee_exp/
    mkdir -p ${newpath}/vendor_aee
    cp -rf /data/oppo/log/vendor_temp/vendor_aee/* ${newpath}/vendor_aee

    rm -rf /data/oppo/log/vendor_temp
}
#endif /* OPLUS_FEATURE_LOGKIT */

function dumpsysInfo(){
    if [ ! -d ${SDCARD_LOG_TRIGGER_PATH} ];then
        mkdir -p ${SDCARD_LOG_TRIGGER_PATH}
    fi
    dumpsys > ${SDCARD_LOG_TRIGGER_PATH}/dumpsys_all_${CURTIME}.txt;
}
function dumpStateInfo(){
    if [ ! -d ${SDCARD_LOG_TRIGGER_PATH} ];then
        mkdir -p ${SDCARD_LOG_TRIGGER_PATH}
    fi
    dumpstate > ${SDCARD_LOG_TRIGGER_PATH}/dumpstate_${CURTIME}.txt
}
function topInfo(){
    if [ ! -d ${SDCARD_LOG_TRIGGER_PATH} ];then
        mkdir -p ${SDCARD_LOG_TRIGGER_PATH}
    fi
    top -n 1 > ${SDCARD_LOG_TRIGGER_PATH}/top_${CURTIME}.txt;
}
function psInfo(){
    if [ ! -d ${SDCARD_LOG_TRIGGER_PATH} ];then
        mkdir -p ${SDCARD_LOG_TRIGGER_PATH}
    fi
    ps > ${SDCARD_LOG_TRIGGER_PATH}/ps_${CURTIME}.txt;
}
function serviceListInfo(){
    if [ ! -d ${SDCARD_LOG_TRIGGER_PATH} ];then
        mkdir -p ${SDCARD_LOG_TRIGGER_PATH}
    fi
    service list > ${SDCARD_LOG_TRIGGER_PATH}/service_list_${CURTIME}.txt;
}
function dumpStorageInfo() {
    STORAGE_PATH=${SDCARD_LOG_TRIGGER_PATH}/storage
    if [ ! -d ${STORAGE_PATH} ];then
        mkdir -p ${STORAGE_PATH}
    fi

    mount > ${STORAGE_PATH}/mount.txt
    dumpsys devicestoragemonitor > ${STORAGE_PATH}/dumpsys_devicestoragemonitor.txt
    dumpsys mount > ${STORAGE_PATH}/dumpsys_mount.txt
    dumpsys diskstats > ${STORAGE_PATH}/dumpsys_diskstats.txt
    du -H /data > ${STORAGE_PATH}/diskUsage.txt
}

function mvrecoverylog() {
    echo "mvrecoverylog begin"
    mkdir -p ${SDCARD_LOG_BASE_PATH}/recovery_log
    mv /cache/recovery/* ${SDCARD_LOG_BASE_PATH}/recovery_log
    echo "mvrecoverylog end"
}

function customdmesg() {
    echo "customdmesg begin"
    chmod 777 -R data/oppo_log/
    echo "customdmesg end"
}

function checkAeeLogs() {
    echo "checkAeeLogs begin"
    setprop sys.move.aeevendor.ready 0
    cp -rf /data/vendor/aee_exp/db.* /data/aee_exp/
    rm -rf /data/vendor/aee_exp/db.*
    restorecon -RF /data/aee_exp/
    chmod 777 -R /data/aee_exp/
    setprop sys.move.aeevendor.ready 1
    echo "checkAeeLogs end"
}

function DumpEnvironment(){
    setprop sys.dumpenvironment.finished 1
}

# Kun.Hu@TECH.BSP.Stability.Phoenix, 2019/4/17, fix the core domain limits to search hang_oppo dirent
function remount_opporeserve2() {
    HANGOPPO_DIR_REMOUNT_POINT="/data/oppo/log/opporeserve/media/log/hang_oppo"
    if [ ! -d ${HANGOPPO_DIR_REMOUNT_POINT} ]; then
        mkdir -p ${HANGOPPO_DIR_REMOUNT_POINT}
    fi
    chmod -R 0770 /data/oppo/log/opporeserve
    chgrp -R system /data/oppo/log/opporeserve
    chown -R system /data/oppo/log/opporeserve
    mount /mnt/vendor/opporeserve/media/log/hang_oppo ${HANGOPPO_DIR_REMOUNT_POINT}
}

#ifdef OPLUS_FEATURE_SHUTDOWN_DETECT
#Liang.Zhang@TECH.Storage.Stability.OPPO_SHUTDOWN_DETECT, 2019/04/28, Add for shutdown detect
function remount_opporeserve2_shutdown() {
    OPPORESERVE2_REMOUNT_POINT="/data/oppo/log/opporeserve/media/log/shutdown"
    if [ ! -d ${OPPORESERVE2_REMOUNT_POINT} ]; then
        mkdir ${OPPORESERVE2_REMOUNT_POINT}
    fi
    chmod 0770 /data/oppo/log/opporeserve
    chgrp system /data/oppo/log/opporeserve
    chown system /data/oppo/log/opporeserve
    mount /mnt/vendor/opporeserve/media/log/shutdown ${OPPORESERVE2_REMOUNT_POINT}
}
#endif

#Xuefeng.Peng@PSW.AD.Performance.Storage.1721598, 2018/12/26, Add for customize version to control sdcard
#Kang.Zou@PSW.AD.Performance.Storage.1721598, 2019/10/17, Add for customize version to control sdcard with new methods
function exstorage_support() {
    exStorage_support=`getprop persist.sys.exStorage_support`
    if [ x"${exStorage_support}" == x"1" ]; then
        #echo 1 > /sys/class/mmc_host/mmc0/exStorage_support
        echo 1 > /sys/bus/mmc/drivers_autoprobe
        mmc_devicename=$(ls /sys/bus/mmc/devices | grep "mmc0:")
        if [ -n "$mmc_devicename" ];then
            echo "$mmc_devicename" > /sys/bus/mmc/drivers/mmcblk/bind
        fi
        #echo "fsck test start" >> /data/media/0/fsck.txt

        #DATE=`date +%F-%H-%M-%S`
        #echo "${DATE}" >> /data/media/0/fsck.txt
        #echo "fsck test end" >> /data/media/0/fsck.txt
    fi
    if [ x"${exStorage_support}" == x"0" ]; then
        #echo 0 > /sys/class/mmc_host/mmc0/exStorage_support
        echo 0 > /sys/bus/mmc/drivers_autoprobe
        mmc_devicename=$(ls /sys/bus/mmc/devices | grep "mmc0:")
        if [ -n "$mmc_devicename" ];then
            echo "$mmc_devicename" > /sys/bus/mmc/drivers/mmcblk/unbind
        fi
        #echo "fsck test111 start" >> /data/media/0/fsck.txt

        #DATE=`date +%F-%H-%M-%S`
        #echo "${DATE}" >> /data/media/0/fsck.txt
        #echo "fsck test111 end" >> /data/media/0/fsck.txt
    fi
}

#Xiaomin.Yang@PSW.CN.BT.Basic.Customize.1586031,2018/12/02, Add for updating wcn firmware by sau_res
function wcnfirmwareupdate(){

    saufwdir="/data/oppo/common/sau_res/res/SAU-AUTO_LOAD_FW-10/"
    pushfwdir="/data/misc/firmware/push/"
    if [ -f ${saufwdir}/ROMv4_be_patch_1_0_hdr.bin ]; then
        cp  ${saufwdir}/ROMv4_be_patch_1_0_hdr.bin  ${pushfwdir}
        chown system:system ${pushfwdir}/ROMv4_be_patch_1_0_hdr.bin
        chmod 666 ${pushfwdir}/ROMv4_be_patch_1_0_hdr.bin
    fi

    if [ -f ${saufwdir}/ROMv4_be_patch_1_1_hdr.bin ]; then
        cp  ${saufwdir}/ROMv4_be_patch_1_1_hdr.bin  ${pushfwdir}
        chown system:system ${pushfwdir}/ROMv4_be_patch_1_1_hdr.bin
        chmod 666 ${pushfwdir}/ROMv4_be_patch_1_1_hdr.bin
    fi

    if [ -f ${saufwdir}/WIFI_RAM_CODE_6759 ]; then
       cp  ${saufwdir}/WIFI_RAM_CODE_6759  ${pushfwdir}
       chown system:system ${pushfwdir}/WIFI_RAM_CODE_6759
       chmod 666 ${pushfwdir}/WIFI_RAM_CODE_6759
    fi

    if [ -f ${saufwdir}/soc2_0_patch_mcu_3_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_patch_mcu_3_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_patch_mcu_3_1_hdr.bin
       chmod 666  ${pushfwdir}/soc2_0_patch_mcu_3_1_hdr.bin
    fi

    if [ -f ${saufwdir}/soc2_0_ram_mcu_3_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_ram_mcu_3_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_ram_mcu_3_1_hdr.bin
       chmod 666  ${pushfwdir}/soc2_0_ram_mcu_3_1_hdr.bin
    fi

    if [ -f ${saufwdir}/soc2_0_ram_bt_3_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_ram_bt_3_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_ram_bt_3_1_hdr.bin
       chmod 666 ${pushfwdir}/soc2_0_ram_bt_3_1_hdr.bin
    fi

    if [ -f ${saufwdir}/soc2_0_ram_wifi_3_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_ram_wifi_3_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_ram_wifi_3_1_hdr.bin
       chmod 666 ${pushfwdir}/soc2_0_ram_wifi_3_1_hdr.bin
    fi

    if [ -f ${saufwdir}/WIFI_RAM_CODE_soc2_0_3_1.bin ]; then
       cp  ${saufwdir}/WIFI_RAM_CODE_soc2_0_3_1.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/WIFI_RAM_CODE_soc2_0_3_1.bin
       chmod 666 ${pushfwdir}/WIFI_RAM_CODE_soc2_0_3_1.bin
    fi

    if [ -f ${saufwdir}/soc2_0_patch_mcu_3a_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_patch_mcu_3a_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_patch_mcu_3a_1_hdr.bin
       chmod 666  ${pushfwdir}/soc2_0_patch_mcu_3a_1_hdr.bin
    fi

    if [ -f ${saufwdir}/soc2_0_ram_mcu_3a_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_ram_mcu_3a_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_ram_mcu_3a_1_hdr.bin
       chmod 666  ${pushfwdir}/soc2_0_ram_mcu_3a_1_hdr.bin
    fi

    if [ -f ${saufwdir}/soc2_0_ram_bt_3a_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_ram_bt_3a_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_ram_bt_3a_1_hdr.bin
       chmod 666 ${pushfwdir}/soc2_0_ram_bt_3a_1_hdr.bin
    fi

    if [ -f ${saufwdir}/soc2_0_ram_wifi_3a_1_hdr.bin ]; then
       cp  ${saufwdir}/soc2_0_ram_wifi_3a_1_hdr.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/soc2_0_ram_wifi_3a_1_hdr.bin
       chmod 666 ${pushfwdir}/soc2_0_ram_wifi_3a_1_hdr.bin
    fi

    if [ -f ${saufwdir}/WIFI_RAM_CODE_soc2_0_3a_1.bin ]; then
       cp  ${saufwdir}/WIFI_RAM_CODE_soc2_0_3a_1.bin  ${pushfwdir}
       chown system:system ${pushfwdir}/WIFI_RAM_CODE_soc2_0_3a_1.bin
       chmod 666 ${pushfwdir}/WIFI_RAM_CODE_soc2_0_3a_1.bin
    fi

    if [ -f ${saufwdir}/push.log ]; then
       cp  ${saufwdir}/push.log  ${pushfwdir}
    fi

}

function wcnfirmwareupdatedump(){

    logfwdir="/data/misc/firmware/"
    wifidir="/data/misc/wifi/"
    if [ -f ${logfwdir}/wcn_fw_update_result.conf ]; then
       cp  ${logfwdir}/wcn_fw_update_result.conf  ${wifidir}
       chown wifi:wifi ${wifidir}/wcn_fw_update_result.conf
       chmod 777  ${wifidir}/wcn_fw_update_result.conf
    fi
}

#ifdef OPLUS_FEATURE_WIFI_CONNECTFAILED
#Add for collect wifi connect fail log
function collectWifiConnectLog() {
    boot_completed=`getprop sys.boot_completed`
    while [ x${boot_completed} != x"1" ];do
        sleep 2
        boot_completed=`getprop sys.boot_completed`
    done
    wifiConnectLogPath="/data/oppo_log/wifi_connect_log"
    if [ -d  ${wifiConnectLogPath} ];then
        rm -rf ${wifiConnectLogPath}
    fi

    if [ ! -d  ${wifiConnectLogPath} ];then
        mkdir -p ${wifiConnectLogPath}
    fi

    # collect driver and firmware log
    cnss_pid=`getprop vendor.oppo.wifi.cnss_diag_pid`
    if [[ "w${cnss_pid}" != "w" ]];then
        kill -s SIGUSR1 $cnss_pid
        sleep 2
        mv /data/vendor/wifi/buffered_wlan_logs/* $wifiConnectLogPath
        chmod 666 ${wifiConnectLogPath}/buffered*
    fi

    dmesg > ${wifiConnectLogPath}/dmesg.txt
    /system/bin/logcat -b main -b system -f ${wifiConnectLogPath}/android.txt -r10240 -v threadtime *:V
}

function packWifiConnectLog() {
    wifiConnectLogPath="/data/oppo_log/wifi_connect_log"
    DCS_WIFI_LOG_PATH="/data/oppo/coloros/dcs/netlog"
    logType=`getprop sys.oplus.wifi.connect.log.type`
    logReason=`getprop sys.oplus.wifi.connect.log.reason`
    logFid=`getprop sys.oplus.wifi.connect.log.fid`
    version=`getprop ro.build.version.ota`

    if [ ! -d  ${wifiConnectLogPath} ] || [ ! -d ${DCS_WIFI_LOG_PATH} ];then
        return
    fi

    if [ "w${logReason}" == "w" ] || [ "w${logFid}" == "w" ] || [ "w${logType}" == "w" ];then
        rm -rf ${wifiConnectLogPath}
        return
    fi

    dumpsys wifi > ${wifiConnectLogPath}/dumpsys_wifi.txt

    $XKIT tar -czvf  ${wifiConnectLogPath}/${logReason}.tar.gz -C ${wifiConnectLogPath} ${wifiConnectLogPath}
    abs_file=${wifiConnectLogPath}/${logReason}.tar.gz
    targetFile="${logType}@${logFid}@${version}@${logReason}.tar.gz"
    mv ${abs_file} ${DCS_WIFI_LOG_PATH}/${targetFile}

    chmod 777 ${DCS_WIFI_LOG_PATH}/${targetFile}

    setprop sys.oplus.wifi.connect.log.stop 0
    setprop sys.oplus.wifi.connect.log.fid 0
    setprop sys.oplus.wifi.connect.log.reason 0
    setprop sys.oplus.wifi.connect.log.type 0
    rm -rf ${wifiConnectLogPath}
}
#end  /* OPLUS_FEATURE_WIFI_CONNECTFAILED */

#Guotian.Wu add for wifi p2p connect fail log
function collectWifiP2pLog() {
    boot_completed=`getprop sys.boot_completed`
    while [ x${boot_completed} != x"1" ];do
        sleep 2
        boot_completed=`getprop sys.boot_completed`
    done
    wifiP2pLogPath="/data/oppo_log/wifi_p2p_log"
    if [ ! -d  ${wifiP2pLogPath} ];then
        mkdir -p ${wifiP2pLogPath}
    fi

    # collect driver and firmware log
    cnss_pid=`getprop vendor.oppo.wifi.cnss_diag_pid`
    if [[ "w${cnss_pid}" != "w" ]];then
        kill -s SIGUSR1 $cnss_pid
        sleep 2
        mv /data/vendor/wifi/buffered_wlan_logs/* $wifiP2pLogPath
        chmod 666 ${wifiP2pLogPath}/buffered*
    fi

    dmesg > ${wifiP2pLogPath}/dmesg.txt
    /system/bin/logcat -b main -b system -f ${wifiP2pLogPath}/android.txt -r10240 -v threadtime *:V
}

function packWifiP2pFailLog() {
    wifiP2pLogPath="/data/oppo_log/wifi_p2p_log"
    DCS_WIFI_LOG_PATH=`getprop oppo.wifip2p.connectfail`
    logReason=`getprop oppo.wifi.p2p.log.reason`
    logFid=`getprop oppo.wifi.p2p.log.fid`
    version=`getprop ro.build.version.ota`

    if [ "w${logReason}" == "w" ];then
        return
    fi

    if [ ! -d ${DCS_WIFI_LOG_PATH} ];then
        mkdir -p ${DCS_WIFI_LOG_PATH}
        chown system:system ${DCS_WIFI_LOG_PATH}
        chmod -R 777 ${DCS_WIFI_LOG_PATH}
    fi

    if [ ! -d  ${wifiP2pLogPath} ];then
        return
    fi

    $XKIT tar -czvf  ${DCS_WIFI_LOG_PATH}/${logReason}.tar.gz -C ${wifiP2pLogPath} ${wifiP2pLogPath}
    abs_file=${DCS_WIFI_LOG_PATH}/${logReason}.tar.gz

    fileName="wifip2p_connect_fail@${logFid}@${version}@${logReason}.tar.gz"
    mv ${abs_file} ${DCS_WIFI_LOG_PATH}/${fileName}
    chown system:system ${DCS_WIFI_LOG_PATH}/${fileName}
    setprop sys.oppo.wifi.p2p.log.stop 0
    rm -rf ${wifiP2pLogPath}
}

#Li.Liu@PSW.AD.Stability.Crash.1296298, 2018/03/14, Add for trying to recover from sysetm hang
function recover_hang() {
 sleep 30
 boot_completed=`getprop sys.oppo.boot_completed`
 if [ x${boot_completed} != x"1" ]; then
    #after 20s, scan system has not finished, use debuggerd to catch system_server native trace
    system_server_pid=`ps -A | grep system_server | $XKIT awk '{print $2}'`
    debuggerd -b ${system_server_pid} > /data/system/dropbox/recover_hang_${system_server_pid}_$(date +%F-%H-%M-%S)_30;
 fi
 #sleep more 70s for the first time to boot
 sleep 70
 boot_completed=`getprop sys.oppo.boot_completed`
 if [ x${boot_completed} != x"1" ]; then
    system_server_pid=`ps -A | grep system_server | $XKIT awk '{print $2}'`
    #use debuggerd to catch system_server native trace
    debuggerd -b ${system_server_pid} > /dev/null;
 fi
}

#Add for mount mnt/vendor/opporeserve/stamp to data/oppo/log/stamp
function remount_opporeserve2_stamp_to_data() {
    DATA_STAMP_MOUNT_POINT="/data/oppo/log/stamp"
    OPPORESERVE_STAMP_MOUNT_PATH="/mnt/vendor/opporeserve"
    OPPORESERVE_STAMP_MOUNT_POINT="/mnt/vendor/opporeserve/media/log/stamp"
    if [ -d ${OPPORESERVE_STAMP_MOUNT_PATH} ]; then
        echo "opporeserve path exist"
        if [ ! -d ${DATA_STAMP_MOUNT_POINT} ]; then
            mkdir ${DATA_STAMP_MOUNT_POINT}
        fi
        chmod -R 0777 ${DATA_STAMP_MOUNT_POINT}
        chown -R system ${DATA_STAMP_MOUNT_POINT}
        chgrp -R system ${DATA_STAMP_MOUNT_POINT}
        if [ ! -d ${OPPORESERVE_STAMP_MOUNT_POINT} ]; then
            mkdir ${OPPORESERVE_STAMP_MOUNT_POINT}
        fi
        chmod -R 0777 ${OPPORESERVE_STAMP_MOUNT_POINT}
        chown -R system ${OPPORESERVE_STAMP_MOUNT_POINT}
        chgrp -R system ${OPPORESERVE_STAMP_MOUNT_POINT}
        mount ${OPPORESERVE_STAMP_MOUNT_POINT} ${DATA_STAMP_MOUNT_POINT}
        restorecon -RF ${DATA_STAMP_MOUNT_POINT}
    fi
}

#Shuangquan.du@PSW.AD.Recovery.0, 2019/07/03, add for generate runtime prop
function generate_runtime_prop() {
    getprop | sed -r 's|\[||g;s|\]||g;s|: |=|' | sed 's|ro.cold_boot_done=true||g' > /cache/runtime.prop
    chown root:root /cache/runtime.prop
    chmod 600 /cache/runtime.prop
    sync
}
#endif

#Qilong.Ao@ANDROID.BIOMETRICS, 2020/10/16, Add for adb sync
function oplussync() {
    sync
}
#endif

#add for oidt begin
#PanZhuan@BSP.Tools, 2020/10/21, modify for way of OIDT log collection changed, please contact me for new reqirement in the future, or your new requiement may not be applied in OIDT correctly
function oidtlogs() {
    # this prop is set means the value path will be removed
    removed_path=`getprop sys.oidt.remove_path`
    if [ "$removed_path" ];then
        traceTransferState "remove path ${removed_path}"
        rm -rf ${removed_path}
        setprop sys.oidt.remove_path ''
        return
    fi

    traceTransferState "oidtlogs start... "
    setprop sys.oppo.oidtlogs 0

    logTypes=`getprop sys.oppo.logTypes`
    if [ "$logTypes" = "" ];then
        logTypes=`getprop sys.oidt.log_types`
    fi

    log_path=`getprop sys.oidt.log_path`

    if [ "$log_path" ];then
        oidt_root=${log_path}
    else
        oidt_root="sdcard/OppoStamp"
    fi

    mkdir -p ${oidt_root}
    traceTransferState "oidt root: ${oidt_root}"

    log_config_file=`getprop sys.oidt.log_config`
    traceTransferState "log config file: ${log_config_file} "

    if [ "$log_config_file" ];then
        setprop sys.oidt.log_ready 0
        paths=`cat ${log_config_file}`

        for file_path in ${paths};do
            # create parent directory of each path
            dest_path=${oidt_root}${file_path%/*}
            # replace dunplicate character '//' with '/' in directory
            dest_path=${dest_path//\/\//\/}
            mkdir -p ${dest_path}
            traceTransferState "copy ${file_path} "
            cp -rf ${file_path} ${dest_path}
        done

        chmod -R 777 ${oidt_root}

        setprop sys.oidt.log_ready 1
        setprop sys.oidt.log_config ''
    elif [ "$logTypes" = "" ] || [ "$logTypes" = "100" ];then
        collect_stamp_config
        logStable
        logPerformance
        logPower
    else
        collect_stamp_config
        arr=${logTypes//,/ }
        for each in ${arr[*]}
        do
            if [ "$each" = "101" ];then
                logStable
            elif [ "$each" = "102" ];then
                logPerformance
            elif [ "$each" = "103" ];then
                logPower
            fi
        done
    fi

    setprop sys.oppo.logTypes ''
    setprop sys.oidt.log_types ''
    setprop sys.oidt.log_path ''
    setprop sys.oppo.oidtlogs 1
    traceTransferState "oidtlogs end "
}

function collect_stamp_config() {
    mkdir -p ${oidt_root}/config
    cp system/etc/sys_stamp_config.xml ${oidt_root}/config/
    cp data/system/sys_stamp_config.xml ${oidt_root}/config/
}

function logStable(){
    mkdir -p ${oidt_root}/log/stable
    cp -r data/oppo/log/DCS/de/minidump/ ${oidt_root}/log/stable
    cp -r data/oppo/log/DCS/en/minidump/ ${oidt_root}/log/stable
    cp -r data/oppo/log/DCS/en/AEE_DB/ ${oidt_root}/log/stable
    cp -r data/vendor/mtklog/aee_exp/ ${oidt_root}/log/stable
    cp -r data/oppo/log/DCS/en/hang_oppo ${oidt_root}/log/stable
    cp -r data/oppo/log/opporeserve/media/log/hang_oppo ${oidt_root}/log/stable
}

function logPerformance(){
    mkdir -p ${oidt_root}/log/performance
    cat /proc/meminfo > ${oidt_root}/log/performance/meminfo_fs.txt
    dumpsys meminfo > ${oidt_root}/log/performance/meminfo_dump.txt
    cat proc/slabinfo > ${oidt_root}/log/performance/slabinfo_fs.txt
}

function logPower(){
    mkdir -p ${oidt_root}/log/power
    mkdir -p ${oidt_root}/log/power/trace_viewer/de
    mkdir -p ${oidt_root}/log/power/trace_viewer/en
    mkdir -p ${oidt_root}/log/power/trace_viewer_bp/de
    mkdir -p ${oidt_root}/log/power/Otrace
    cp -r /data/oppo/log/DCS/de/trace_viewer ${oidt_root}/log/power/trace_viewer/de
    cp -r /data/oppo/log/DCS/en/trace_viewer ${oidt_root}/log/power/trace_viewer/en
    cp -r /data/oppo/log/DCS/de/trace_viewer_bp ${oidt_root}/log/power/trace_viewer_bp/de
    cp -r /storage/emulated/0/Android/data/com.coloros.athena/files/Documents ${oidt_root}/log/power/Otrace
    cp -r /data/oppo/psw/powermonitor_backup ${oidt_root}/log/power
    dumpsys batterystats --thermalrec > ${oidt_root}/log/power/thermalrec.txt
    dumpsys batterystats --thermallog > ${oidt_root}/log/power/thermallog.txt
}
#add for oidt end

#Bin.Li@BSP.Fingerprint.Secure 2018/12/27, Add for oae get bootmode
function oae_bootmode(){
    boot_modei_info=`cat /sys/power/app_boot`
    if [ "$boot_modei_info" == "kernel" ]; then
        setprop ro.oae.boot.mode kernel
      else
        setprop ro.oae.boot.mode normal
    fi
}

#ifdef OPLUS_BUG_DEBUG
#Miao.Yu@ANDROID.WMS, 2019/11/25, Add for dump wm info
function dumpWm() {
    panicstate=`getprop persist.sys.assert.panic`
    dumpenable=`getprop debug.screencapdump.enable`
    if [ "$panicstate" == "true" ] && [ "$dumpenable" == "true" ]
    then
        if [ ! -d /data/oppo_log/wm/ ];then
        mkdir -p /data/oppo_log/wm/
        fi

        LOGTIME=`date +%F-%H-%M-%S`
        DIR=/data/oppo_log/wm/${LOGTIME}
        mkdir -p ${DIR}
        dumpsys window -a > ${DIR}/windows.txt
        dumpsys activity a > ${DIR}/activities.txt
        dumpsys activity -v top > ${DIR}/top_activity.txt
        dumpsys input > ${DIR}/input.txt
        ps -A > ${DIR}/ps.txt
    fi
}
#endif /* OPLUS_BUG_DEBUG */

#zhaochengsheng@PSW.CN.WiFi.Basic.Custom.2204034, 2019/07/29
#add for Add for:solve camera interference ANT.
function iwprivswapant0(){
    iwpriv wlan0 driver 'SET_CHIP AntSwapManualCtrl 1 0'
    iwpriv wlan0 driver 'SET_CHIP AntSwapManualCtrl 0'
}

function iwprivswapant1(){
    iwpriv wlan0 driver 'SET_CHIP AntSwapManualCtrl 1 1'
}

function iwprivswitchswapant(){
    iwpriv wlan0 driver 'SET_CHIP AntSwapManualCtrl 1 0'
}

#genglin.lian@PSW.CN.WiFi.Connect.Network.2566837, 2019/9/23
#Add enable/disable interface for SmartGear
function disableSmartGear() {
    iwpriv wlan0 driver 'set_chip SmartGear 9 0'
}

function enableSmartGear() {
    iwpriv wlan0 driver 'set_chip SmartGear 9 1'
}

#Junhao.Liang@AD.OppoLog.bug000000, 2020/01/02, Add for OTA to catch log
function resetlogfirstbootbuffer() {
    echo "resetlogfirstbootbuffer start"
    setprop sys.tranfer.finished "resetlogfirstbootbuffer start"
    enable=`getprop persist.sys.assert.panic`
    argfalse='false'
    if [ "${enable}" = "${argfalse}" ]; then
    /system/bin/logcat -G 256K
    fi
    echo "resetlogfirstbootbuffer end"
    setprop sys.tranfer.finished "resetlogfirstbootbuffer end"
}

function logfirstbootmain() {
    echo "logfirstbootmain begin"
    setprop sys.tranfer.finished "logfirstbootmain begin"
    path=/data/oppo_log/firstboot
    mkdir -p ${path}
    /system/bin/logcat -G 5M
    /system/bin/logcat  -f ${path}/android.txt -r10240 -v threadtime *:V
    setprop sys.tranfer.finished "logfirstbootmain end"
    echo "logfirstbootmain end"
}

function logfirstbootevent() {
    echo "logfirstbootevent begin"
    setprop sys.tranfer.finished "logfirstbootevent begin"
    path=/data/oppo_log/firstboot
    mkdir -p ${path}
    /system/bin/logcat -b events -f ${path}/event.txt -r10240 -v threadtime *:V
    setprop sys.tranfer.finished "logfirstbootevent end"
    echo "logfirstbootevent end"
}

function logfirstbootkernel() {
    echo "logfirstbootkernel begin"
    setprop sys.tranfer.finished "logfirstbootkernel begin"
    path=/data/oppo_log/firstboot
    mkdir -p ${path}
    dmesg > ${path}/kinfo_boot.txt
    setprop sys.tranfer.finished "logfirstbootkernel end"
    echo "logfirstbootkernel end"
}

#ifdef VENDOR_EDIT
#Hailong.Liu@ANDROID.MM, 2020/03/18, add for capture native malloc leak on aging_monkey test
function storeSvelteLog() {
    local dest_dir="/data/oppo/heapdump/svelte/"
    local log_file="${dest_dir}/svelte_log.txt"
    local log_dev="/dev/svelte_log"
    local err_file="/data/oppo_log/svelte_err.txt"

    if [ ! -c ${log_dev} ]; then
        echo "svelte ${log_dev} does not exist." >> ${err_file}
        return 1
    fi

    if [ ! -d ${dest_dir} ]; then
        mkdir -p ${dest_dir}
        if [ "$?" -ne "0" ]; then
            echo "svelte mkdir failed." >> ${err_file}
            return 1
        fi
        chmod 0777 ${dest_dir}
    fi

    if [ ! -f ${log_file} ]; then
        echo --------Start `date` >> ${log_file}
        if [ "$?" -ne "0" ]; then
            echo "svelte create file failed." >> ${err_file}
            return 1
        fi
        chmod 0777 ${log_file}
    fi

    while true
    do
        echo --------`date` >> ${log_file}
        /system/bin/svelte logger >> ${log_file}
    done
}
#endif

function chmodDcsEnPath() {
    DCS_EN_PATH=/data/oppo/log/DCS/en
    chmod 777 -R ${DCS_EN_PATH}
}

function logObserver() {
    # 1, data free size
    boot_completed=`getprop sys.boot_completed`
    while [ x${boot_completed} != x"1" ];do
        traceTransferState "log observer:device don't boot completed"
        sleep 10
        boot_completed=`getprop sys.boot_completed`
    done

    FreeSize=`df /data | grep /data | awk '{print $4}'`
    traceTransferState "log observer:free size ${FreeSize}"

    # 2, count log size
    LOG_CONFIG_FILE="/data/oppo/log/config/log_config.log"
    LOG_COUNT_SIZE=0
    if [ -f "${LOG_CONFIG_FILE}" ]; then
        while read -r ITEM_CONFIG
        do
            if [ "" != "${ITEM_CONFIG}" ];then
                #echo "${CURTIME_FORMAT} transfer log config: ${ITEM_CONFIG}"
                SOURCE_PATH=`echo ${ITEM_CONFIG} | awk '{print $2}'`
                if [ -d ${SOURCE_PATH} ];then
                    TEMP_SIZE=`du -s ${SOURCE_PATH} | awk '{print $1}'`
                    LOG_COUNT_SIZE=`expr ${LOG_COUNT_SIZE} + ${TEMP_SIZE}`
                    traceTransferState "path: ${SOURCE_PATH}, ${TEMP_SIZE}/${LOG_COUNT_SIZE}"
                else
                    echo "${CURTIME_FORMAT} path: ${SOURCE_PATH}, No such file or directory"
                fi
            fi
        done < ${LOG_CONFIG_FILE}
    fi

    settings put global logkit_observer_size "${FreeSize}|${LOG_COUNT_SIZE}"
    # settings get global logkit_observer_size
    traceTransferState " log observer:data free and log size: ${FreeSize}|${LOG_COUNT_SIZE}"
}

function traceTransferState() {
    if [ ! -d ${SDCARD_LOG_BASE_PATH} ]; then
        mkdir -p ${SDCARD_LOG_BASE_PATH}
        chmod 770 ${SDCARD_LOG_BASE_PATH} -R
        echo "${CURTIME_FORMAT} TRACETRANSFERSTATE:${SDCARD_LOG_BASE_PATH} " >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    fi

    content=$1
    currentTime=`date "+%Y-%m-%d %H:%M:%S"`
    echo "${currentTime} ${content} " >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
    log -p d -t Debuglog ${content}
}

case "$config" in
# Add for SurfaceFlinger Layer dump
    "layerdump")
        layerdump
        ;;
#Shuangquan.du@PSW.AD.Recovery.0, 2019/07/03, add for generate runtime prop
    "generate_runtime_prop")
        generate_runtime_prop
        ;;
#endif
#Qilong.Ao@ANDROID.BIOMETRICS, 2020/10/16, Add for adb sync
    "oplussync")
        oplussync
        ;;
#endif
#Xuefeng.Peng@PSW.AD.Performance.Storage.1721598, 2018/12/26, Add for abnormal sd card shutdown long time
    "exstorage_support")
        exstorage_support
        ;;
    "gettpinfo")
        gettpinfo
    ;;
    "inittpdebug")
        inittpdebug
    ;;
    "settplevel")
        settplevel
    ;;
#Deliang.Peng, 2017/7/7,add for native watchdog
    "nativedump")
        nativedump
    ;;
#Jianping.Zheng2017/05/08, Add for systemserver futex_wait block check
        "checkfutexwait")
        do_check_systemserver_futexwait_block
    ;;
    "checkfutexwait_wrap")
        checkfutexwait_wrap
#end, add for systemserver futex_wait block check
#Jianping.Zheng 2017/04/04, Add for record performance
    ;;
        "perf_record")
        perf_record
    ;;
        "powerlog")
        powerlog
    ;;
    #Fei.Mo, 2017/09/01 ,Add for power monitor top info
    "thermal_top")
        thermalTop
    #end, Add for power monitor top info
    ;;
    "cleanlog")
        cleanlog
    ;;
    "cleardatadebuglog")
        clearDataDebugLog
    ;;
#Linjie.Xu@PSW.AD.Power.PowerMonitor.1104067, 2018/01/17, Add for OppoPowerMonitor get dmesg at O
        "kernelcacheforopm")
        kernelcacheforopm
    ;;
        "psforopm")
        psforopm
    ;;
        "logcatMainCacheForOpm")
        logcatMainCacheForOpm
    ;;
        "logcatEventCacheForOpm")
        logcatEventCacheForOpm
    ;;
        "logcatRadioCacheForOpm")
        logcatRadioCacheForOpm
    ;;
        "catchBinderInfoForOpm")
        catchBinderInfoForOpm
    ;;
        "catchBattertFccForOpm")
        catchBattertFccForOpm
    ;;
        "catchTopInfoForOpm")
        catchTopInfoForOpm
    ;;
        "getPropForOpm")
        getPropForOpm
    ;;
        "dumpsysSurfaceFlingerForOpm")
        dumpsysSurfaceFlingerForOpm
    ;;
        "dumpsysSensorserviceForOpm")
        dumpsysSensorserviceForOpm
    ;;
        "dumpsysBatterystatsForOpm")
        dumpsysBatterystatsForOpm
    ;;
        "dumpsysBatterystatsOplusCheckinForOpm")
        dumpsysBatterystatsOplusCheckinForOpm
    ;;
        "dumpsysBatterystatsCheckinForOpm")
        dumpsysBatterystatsCheckinForOpm
    ;;
        "dumpsysMediaForOpm")
        dumpsysMediaForOpm
    ;;
        "logcusMainForOpm")
        logcusMainForOpm
    ;;
        "logcusEventForOpm")
        logcusEventForOpm
    ;;
        "logcusRadioForOpm")
        logcusRadioForOpm
    ;;
        "logcusKernelForOpm")
        logcusKernelForOpm
    ;;
        "logcusTCPForOpm")
        logcusTCPForOpm
    ;;
        "customDiaglogForOpm")
        customDiaglogForOpm
    ;;
    "screen_record_backup")
        screen_record_backup
        ;;
    "pwkdumpon")
        pwkdumpon
        ;;
    "pwkdumpoff")
        pwkdumpoff
        ;;
    "mrdumpon")
        mrdumpon
        ;;
    "mrdumpoff")
        mrdumpoff
        ;;
    "transfermtklog")
        transferMtkLog
        ;;
#Miao.Yu@ANDROID.WMS, 2019/11/25, Add for dump wm info
    "dumpWm")
        dumpWm
        ;;
    "psinfo")
        psInfo
        ;;
    "topinfo")
        topInfo
        ;;
    "servicelistinfo")
        serviceListInfo
        ;;
    "dumpsysinfo")
        dumpsysInfo
        ;;
#Wenshuai.Chen@RM.AD.OppoDebug.LogKit.NA, 2020/11/27, Add for bugreport log
    "dump_bugreport")
        dump_bugreport
        ;;
    "dumpstate")
        dumpStateInfo
        ;;
    "dumpstorageinfo")
        dumpStorageInfo
        ;;
        "mvrecoverylog")
        mvrecoverylog
    ;;
        "customdmesg")
        customdmesg
    ;;
        "checkAeeLogs")
        checkAeeLogs
    ;;
        "dumpenvironment")
        DumpEnvironment
    ;;
        "slabinfoforhealth")
        slabinfoforhealth
    ;;
        "meminfoforhealth")
        meminfoforhealth
    ;;
        "dmaprocsforhealth")
        dmaprocsforhealth
    ;;
    #ifdef OPLUS_FEATURE_EAP
    #Haifei.Liu@ANDROID.RESCONTROL, 2020/08/18, Add for copy binder_info
    "copyEapBinderInfo")
        copyEapBinderInfo
    ;;
    #endif /* OPLUS_FEATURE_EAP */
#Xiaomin.Yang@PSW.CN.BT.Basic.Customize.1586031,2018/12/02, Add for updating wcn firmware by sau
    "wcnfirmwareupdate")
        wcnfirmwareupdate
        ;;
    "wcnfirmwareupdatedump")
        wcnfirmwareupdatedump
        ;;
# Kun.Hu@PSW.TECH.RELIABILTY, 2019/1/3, fix the core domain limits to search /mnt/vendor/opporeserve
        "remount_opporeserve2")
        remount_opporeserve2
    ;;
#ifdef OPLUS_FEATURE_SHUTDOWN_DETECT
#Liang.Zhang@TECH.Storage.Stability.OPPO_SHUTDOWN_DETECT, 2019/04/28, Add for shutdown detect
        "remount_opporeserve2_shutdown")
        remount_opporeserve2_shutdown
    ;;
#endif
#Li.Liu@PSW.AD.Stability.Crash.1296298, 2018/03/14, Add for trying to recover from sysetm hang
    "recover_hang")
        recover_hang
        ;;
#Bin.Li@BSP.Fingerprint.Secure 2018/12/27, Add for oae get bootmode
        "oae_bootmode")
        oae_bootmode
    ;;
    "cleanpcmdump")
        cleanpcmdump
    ;;
#Add for mount mnt/vendor/opporeserve/stamp to data/oppo/log/stamp
        "remount_opporeserve2_stamp_to_data")
        remount_opporeserve2_stamp_to_data
    ;;
        "oidtlogs")
        oidtlogs
    ;;
#zhaochengsheng@PSW.CN.WiFi.Basic.Custom.2204034, 2019/07/29
#add for Add for:solve camera interference ANT.
    "iwprivswapant0")
        iwprivswapant0
    ;;
    "iwprivswapant1")
        iwprivswapant1
    ;;
    "iwprivswitchswapant")
        iwprivswitchswapant
    ;;

#genglin.lian@PSW.CN.WiFi.Connect.Network.23456788, 2019/9/23
#Add enable/disable interface for SmartGear
    "disableSmartGear")
        disableSmartGear
    ;;
    "enableSmartGear")
        enableSmartGear
    ;;
#add for firstboot log
        "resetlogfirstbootbuffer")
        resetlogfirstbootbuffer
    ;;
        "logfirstbootmain")
        logfirstbootmain
    ;;
        "logfirstbootevent")
        logfirstbootevent
    ;;
        "logfirstbootkernel")
        logfirstbootkernel
    ;;
	"transferUser")
        transferUser
    ;;
	"dump_system")
        getSystemStatus
    ;;
    "transfer_data_vendor")
        transferDataVendor
    ;;
    "transfer_anrtomb")
        transferAnrTomb
    ;;
    "testtransfersystem")
        testTransferSystem
    ;;
	"testtransferroot")
        testTransferRoot
    ;;
#ifdef OPLUS_FEATURE_MEMLEAK_DETECT
        "storeSvelteLog")
        storeSvelteLog
    ;;
#endif /* OPLUS_FEATURE_MEMLEAK_DETECT */
    "chmoddcsenpath")
        chmodDcsEnPath
    ;;
    "backup_minidumplog")
        backupMinidump
    ;;
    "logobserver")
        logObserver
    ;;
#ifdef OPLUS_FEATURE_WIFI_CONNECTFAILED
#Add for collect wifi connect fail log
    "collectWifiConnectLog")
        collectWifiConnectLog
    ;;
    "packWifiConnectLog")
        packWifiConnectLog
    ;;
#endif  /* OPLUS_FEATURE_WIFI_CONNECTFAILED */
       *)

      ;;
esac
