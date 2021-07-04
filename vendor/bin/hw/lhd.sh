#! /vendor/bin/sh
SILENT_LOGGING_9900=/data/vendor/gps/silentGnssLogging
SILENT_LOGGING_ISSUETRACKER=/data/vendor/gps/silentGnssLoggingIssueTracker

LHD_CONFIG_FILE=/vendor/etc/sensor/lhd.conf
LHD_DAEMON_FILE=/vendor/bin/hw/lhd

if [ -d "$SILENT_LOGGING_ISSUETRACKER" ] ; then 
	LHD_CONFIG_FILE=/vendor/etc/sensor/lhd.issuetracker.conf
fi

if [ -d "$SILENT_LOGGING_9900" ] ; then 
	LHD_CONFIG_FILE=/vendor/etc/sensor/lhd.debug.conf
fi

exec $LHD_DAEMON_FILE $LHD_CONFIG_FILE