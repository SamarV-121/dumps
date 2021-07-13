#! /system/bin/sh

SDCARD_LOG_BASE_PATH=${BASE_PATH}/Android/data/com.coloros.logkit/files/Log
DATA_LOG_PATH=/data/debugging

config="$1"

#------# collect method #--------------------------------------------------------------------------#
function logcatMain(){
    panicenable=`getprop persist.sys.assert.panic`
    camerapanic=`getprop persist.sys.assert.panic.camera`
    DATA_LOG_APPS_PATH=`getprop sys.oppo.logkit.appslog`
    traceTransferState "logcat main:path=${DATA_LOG_APPS_PATH}, size=${androidSize}, Nums=${androidCount}"
    if [ "${panicenable}" = "true" ] || [ x"${camerapanic}" = x"true" ] && [ "${tmpMain}" != "" ]; then
        logdsize=`getprop persist.logd.size`
        if [ "${logdsize}" = "" ]; then
            /system/bin/logcat -G 5M
        fi

        /system/bin/logcat -f ${DATA_LOG_APPS_PATH}/android.txt -r ${androidSize} -n ${androidCount} -v threadtime -A
    else
        setprop ctl.stop logcatsdcard
    fi
}

function logcatRadio(){
    panicenable=`getprop persist.sys.assert.panic`
    DATA_LOG_APPS_PATH=`getprop sys.oppo.logkit.appslog`
    echo "logcat radio: radioSize=${radioSize}, radioCount=${radioCount}"
    if [ "${panicenable}" = "true" ] && [ "${tmpRadio}" != "" ]; then
        /system/bin/logcat -b radio -f ${DATA_LOG_APPS_PATH}/radio.txt -r ${radioSize} -n ${radioCount} -v threadtime -A
    else
        setprop ctl.stop logcatradio
    fi
}

function logcatEvent(){
    panicenable=`getprop persist.sys.assert.panic`
    camerapanic=`getprop persist.sys.assert.panic.camera`
    DATA_LOG_APPS_PATH=`getprop sys.oppo.logkit.appslog`
    echo "logcat event: eventSize=${eventSize}, eventCount=${eventCount}"
    if [ "${panicenable}" = "true" ] || [ x"${camerapanic}" = x"true" ] && [ "${tmpEvent}" != "" ]; then
        /system/bin/logcat -b events -f ${DATA_LOG_APPS_PATH}/events.txt -r ${eventSize} -n ${eventCount} -v threadtime -A
    else
        setprop ctl.stop logcatevent
    fi
}

function logcatKernel(){
    panicenable=`getprop persist.sys.assert.panic`
    camerapanic=`getprop persist.sys.assert.panic.camera`
    DATA_LOG_KERNEL_PATH=`getprop sys.oppo.logkit.kernellog`
    echo "logcat kernel: panicenable=${panicenable} tmpKernel=${tmpKernel}"
    if [ "${panicenable}" = "true" ] || [ x"${camerapanic}" = x"true" ] && [ "${tmpKernel}" != "" ]; then
        /system/system_ext/xbin/klogd -f - -n -x -l 7 | tee - ${DATA_LOG_KERNEL_PATH}/kernel.txt | awk 'NR%400==0'
    fi
}

#------# transfer method #-------------------------------------------------------------------------#
function transferDataVendor(){
    stoptime=`getprop sys.oppo.log.stoptime`
    newpath="${SDCARD_LOG_BASE_PATH}/log@stop@${stoptime}"
    DATA_VENDOR_LOG=/data/oppo/log/data_vendor
    TARGET_DATA_VENDOR_LOG=${newpath}/data_vendor

    if [ -d  ${DATA_VENDOR_LOG} ]; then
        chmod 777 ${DATA_VENDOR_LOG}/ -R
        ALL_SUB_DIR=`ls ${DATA_VENDOR_LOG}`
        for SUB_DIR in ${ALL_SUB_DIR};do
            if [ -d ${DATA_VENDOR_LOG}/${SUB_DIR} ] || [ -f ${DATA_VENDOR_LOG}/${SUB_DIR} ]; then
                checkNumberSizeAndMove "${DATA_VENDOR_LOG}/${SUB_DIR}" "${TARGET_DATA_VENDOR_LOG}/${SUB_DIR}"
            fi
        done
    fi
}

#------# utils method #----------------------------------------------------------------------------#
function initLogSizeAndNums() {
    FreeSize=`df /data | grep /data | awk '{print $4}'`
    GSIZE=`echo | awk '{printf("%d",2*1024*1024)}'`
    traceTransferState "init:data FreeSize:${FreeSize} and GSIZE:${GSIZE}"

    # TODO modified prop to config file
    tmpMain=`getprop persist.sys.log.main`
    tmpRadio=`getprop persist.sys.log.radio`
    tmpEvent=`getprop persist.sys.log.event`
    tmpKernel=`getprop persist.sys.log.kernel`
    tmpTcpdump=`getprop persist.sys.log.tcpdump`
    traceTransferState "init:main=${tmpMain}, radio=${tmpRadio}, event=${tmpEvent}, kernel=${tmpKernel}, tcpdump=${tmpTcpdump}"

    if [ ${FreeSize} -ge ${GSIZE} ]; then
        if [ "${tmpMain}" != "" ]; then
            #get the config size main
            tmpAndroidSize=`set -f;array=(${tmpMain//|/ });echo "${array[0]}"`
            tmpAdnroidCount=`set -f;array=(${tmpMain//|/ });echo "${array[1]}"`
            androidSize=`echo ${tmpAndroidSize} | awk '{printf("%d",$1*1024)}'`
            androidCount=`echo ${FreeSize} 30 50 ${androidSize} | awk '{printf("%d",$1*$2/$3/$4)}'`
            traceTransferState "init:tmpAndroidSize=${tmpAndroidSize}, tmpAdnroidCount=${tmpAdnroidCount}, androidSize=${androidSize}, androidCount=${androidCount}"
            if [ ${androidCount} -ge ${tmpAdnroidCount} ]; then
                androidCount=${tmpAdnroidCount}
            fi
            traceTransferState "init:last androidCount=${androidCount}"
        fi

        if [ "${tmpRadio}" != "" ]; then
            #get the config size radio
            tmpRadioSize=`set -f;array=(${tmpRadio//|/ });echo "${array[0]}"`
            tmpRadioCount=`set -f;array=(${tmpRadio//|/ });echo "${array[1]}"`
            radioSize=`echo ${tmpRadioSize} | awk '{printf("%d",$1*1024)}'`
            radioCount=`echo ${FreeSize} 1 50 ${radioSize} | awk '{printf("%d",$1*$2/$3/$4)}'`
            echo "tmpRadioSize=${tmpRadioSize}; tmpRadioCount=${tmpRadioCount} radioSize=${radioSize} radioCount=${radioCount}"
            if [ ${radioCount} -ge ${tmpRadioCount} ]; then
                radioCount=${tmpRadioCount}
            fi
            echo "last radioCount=${radioCount}"
        fi

        if [ "${tmpEvent}" != "" ]; then
            #get the config size event
            tmpEventSize=`set -f;array=(${tmpEvent//|/ });echo "${array[0]}"`
            tmpEventCount=`set -f;array=(${tmpEvent//|/ });echo "${array[1]}"`
            eventSize=`echo ${tmpEventSize} | awk '{printf("%d",$1*1024)}'`
            eventCount=`echo ${FreeSize} 1 50 ${eventSize} | awk '{printf("%d",$1*$2/$3/$4)}'`
            echo "tmpEventSize=${tmpEventSize}; tmpEventCount=${tmpEventCount} eventSize=${eventSize} eventCount=${eventCount}"
            if [ ${eventCount} -ge ${tmpEventCount} ]; then
                eventCount=${tmpEventCount}
            fi
            echo "last eventCount=${eventCount}"
        fi

        if [ "${tmpTcpdump}" != "" ]; then
            tmpTcpdumpSize=`set -f;array=(${tmpTcpdump//|/ });echo "${array[0]}"`
            tmpTcpdumpCount=`set -f;array=(${tmpTcpdump//|/ });echo "${array[1]}"`
            tcpdumpSize=`echo ${tmpTcpdumpSize} | awk '{printf("%d",$1*1024)}'`
            tcpdumpCount=`echo ${FreeSize} 10 50 ${tcpdumpSize} | awk '{printf("%d",$1*$2/$3/$4)}'`
            echo "tmpTcpdumpSize=${tmpTcpdumpCount}; tmpEventCount=${tmpEventCount} tcpdumpSize=${tcpdumpSize} tcpdumpCount=${tcpdumpCount}"
            ##tcpdump use MB in the order
            tcpdumpSize=${tmpTcpdumpSize}
            if [ ${tcpdumpCount} -ge ${tmpTcpdumpCount} ]; then
                tcpdumpCount=${tmpTcpdumpCount}
            fi
            echo "last tcpdumpCount=${tcpdumpCount}"
        else
            echo "tmpTcpdump is empty"
        fi
    else
        echo "free size is less than 2G"
        androidSize=20480
        androidCount=`echo ${FreeSize} 30 50 ${androidSize} | awk '{printf("%d",$1*$2*1024/$3/$4)}'`
        if [ ${androidCount} -ge 10 ]; then
            androidCount=10
        fi
        radioSize=10240
        radioCount=`echo ${FreeSize} 1 50 ${radioSize} | awk '{printf("%d",$1*$2*1024/$3/$4)}'`
        if [ ${radioCount} -ge 4 ]; then
            radioCount=4
        fi
        eventSize=10240
        eventCount=`echo ${FreeSize} 1 50 ${eventSize} | awk '{printf("%d",$1*$2*1024/$3/$4)}'`
        if [ ${eventCount} -ge 4 ]; then
            eventCount=4
        fi
        tcpdumpSize=50
        tcpdumpCount=`echo ${FreeSize} 10 50 ${tcpdumpSize} | awk '{printf("%d",$1*$2/$3/$4)}'`
        if [ ${tcpdumpCount} -ge 2 ]; then
            tcpdumpCount=2
        fi
    fi

    #LiuHaipeng@NETWORK.DATA.2959182, modify for limit the tcpdump size to 300M and packet size 100 byte for power log type and other log type
    LOG_TYPE=`getprop persist.sys.oppo.log.config`
    if [ "${LOG_TYPE}" == "call" ]; then
        tcpdumpPacketSize=0
    elif [ "${LOG_TYPE}" == "network" ];then
        tcpdumpPacketSize=0
    elif [ "${LOG_TYPE}" == "wifi" ];then
        tcpdumpPacketSize=0
    else
        tcpdumpPacketSize=100
        tcpdumpSizeTotal=300
        tcpdumpCount=`echo ${tcpdumpSizeTotal} ${tcpdumpSize} 1 | awk '{printf("%d",$1/$2)}'`
    fi
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
    content=$1
    currentTime=`date "+%Y-%m-%d %H:%M:%S"`
    echo "${currentTime} ${content} " >> ${SDCARD_LOG_BASE_PATH}/logkit_transfer.log
}

case "$config" in
    "logcat_main")
        initLogSizeAndNums
        logcatMain
        ;;
    "logcat_radio")
        initLogSizeAndNums
        logcatRadio
        ;;
    "logcat_event")
        initLogSizeAndNums
        logcatEvent
        ;;
    "logcat_kernel")
        initLogSizeAndNums
        logcatKernel
        ;;
    "transfer_data_vendor")
        transferDataVendor
    ;;
    "log_observer")
        logObserver
        ;;
    *)
        ;;
esac