SKIPUNZIP=1
ASH_STANDALONE=1

bin_name="sing"
module_path="/data/adb/${bin_name}"
core="update"
asset="update"
busybox="/data/adb/magisk/busybox"
sing_config="${module_path}/sing.config"
sing_config_tmp="$TMPDIR/sing.config"

if [ -f ${sing_config} ]; then
  head ${sing_config} > ${sing_config_tmp}
  source ${sing_config_tmp}
fi

if [ $BOOTMODE ! = true ] ; then
  core="custom"
  asset="custom"
fi

conf_file="${module_path}/confs/${config}"

sing_link="https://github.com/SagerNet/sing-box/releases"
github_api="https://api.github.com/repos/SagerNet/sing-box/releases"

  case "${ARCH}" in
    arm)
      version="linux-armv7"
      ;;
    arm64)
      version="android-arm64"
      ;;
    x86)
      version=""
      ;;
    x64)
      version="android-amd64v3"
      ;;
  esac

  if [ "${core}" = "update" ] ; then
    latest_version=`$busybox wget -qO- ${github_api} | grep -m 1 "tag_name" | awk '{print $2}'`
    latest_version=${latest_version:2:-2}
    download_file="sing-box-${latest_version}-${version}.tar.gz"
    download_path="/sdcard/Download/${download_file}"
    if [ "$latest_version" = "" ] ; then
      ui_print "versionCheck error"
      abort
    fi
    $busybox wget "${sing_link}/download/v${latest_version}/${download_file}" -O "${download_path}" >&2
    if [ "$?" != "0" ] ; then
      ui_print "Download error"
      abort
    fi
  else
    if [ $(ls /sdcard/Download | grep sing-box | grep "${version}.tar.gz") ] ; then
      download_file=$(ls /sdcard/Download | grep sing-box | grep "${version}.tar.gz")
      download_path="/sdcard/Download/${download_file}"
    else
      ui_print "Offline mode error"
      abort
    fi
  fi


  if [ "${asset}" = "update" ] ; then
    $busybox wget https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db -O /sdcard/Download/geoip.db >&2
    if [ "$?" != "0" ] ; then
      ui_print "Download error"
      abort
    fi
    $busybox wget https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db -O /sdcard/Download/geosite.db >&2
    if [ "$?" != "0" ] ; then
      ui_print "Download error"
      abort
    fi
  else
    if [ -f /sdcard/Download/geoip.db ] && [ -f /sdcard/Download/geosite.db ] ; then
      ui_print "Assets found"
    else
      ui_print "Offline mode error"
      abort
    fi
  fi


mkdir -p ${module_path}/run
mkdir -p ${module_path}/confs
mkdir -p ${module_path}/assets
mkdir -p ${module_path}/bin

# install module
unzip -j -o "${ZIPFILE}" 'sing/scripts/*' -d ${module_path}/scripts >&2
if [ ! -d /data/adb/service.d ] ; then
  mkdir -p /data/adb/service.d
fi
unzip -j -o "${ZIPFILE}" 'sing4magisk_service.sh' -d /data/adb/service.d >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive ${module_path}/ 0 0 0755 0644
set_perm_recursive ${module_path}/scripts/ 0 0 0755 0700
set_perm_recursive ${module_path}/bin/ 0 0 0755 0700

set_perm /data/adb/service.d/sing4magisk_service.sh 0 0 0700

chmod ugo+x ${module_path}/scripts/*
chmod ugo+x ${module_path}/bin/*

# stop service
# ${module_path}/scripts/sing.service stop

# install xray execute file
tar --strip-components=1 -xvzf ${download_path} -C ${module_path}/bin/

# start service
# ${module_path}/scripts/sing.service start

# assets
cp /sdcard/Download/geoip.db ${module_path}/assets
cp /sdcard/Download/geosite.db ${module_path}/assets

unzip -j -o "${ZIPFILE}" "sing/etc/sing.config" -d ${module_path} >&2
[ -f ${conf_file} ] || \
unzip -j -o "${ZIPFILE}" "sing/etc/confs/*" -d ${module_path}/confs >&2
unzip -j -o "${ZIPFILE}" "module.prop" -d $MODPATH >&2
