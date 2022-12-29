#!/system/bin/sh

MODDIR=/data/adb/modules/sing4magisk
if [ -n "$(magisk -v | grep lite)" ]; then
  MODDIR=/data/adb/lite_modules/sing4magisk
fi
SCRIPTS_DIR=/data/adb/sing/scripts
source /data/adb/sing/sing.config

start_proxy() {
   ${SCRIPTS_DIR}/sing.service start &&
    if [ "$TPROXY" = "true" ]; then
      ${SCRIPTS_DIR}/sing.tproxy enable &
    fi
}

if [ ! -f /data/adb/sing/manual ] ; then
  echo -n "" > /data/adb/sing/run/service.log
  if [ ! -f ${MODDIR}/disable ] ; then
    start_proxy &>> /data/adb/sing/run/service.log &
  fi
  inotifyd ${SCRIPTS_DIR}/sing.inotify ${MODDIR} &>> /data/adb/sing/run/service.log &
fi
