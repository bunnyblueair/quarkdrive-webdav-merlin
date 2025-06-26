#!/bin/sh
eval `dbus export quarkdrivewebdav_`
source /koolshare/scripts/base.sh
logger "[软件中心]: 正在卸载 quarkdrivewebdav..."
MODULE=quarkdrivewebdav
cd /
/koolshare/scripts/quarkdrivewebdavconfig.sh stop
rm -f /koolshare/init.d/S99quarkdrivewebdav.sh
rm -f /koolshare/scripts/quarkdriveweb*
rm -f /koolshare/webs/Module_quarkdrivewebdav.asp
rm -f /koolshare/res/quarkdrivewebdav*
rm -f /koolshare/res/icon-quarkdrivewebdav.png
rm -f /koolshare/bin/quarkdrive-webdav
rm -fr /tmp/quarkdrivewebdav* >/dev/null 2>&1
values=`dbus list quarkdrivewebdav | cut -d "=" -f 1`
for value in $values
do
  dbus remove $value
done
logger "[软件中心]: 完成 quarkdrivewebdav 卸载"
rm -f /koolshare/scripts/uninstall_quarkdrivewebdav.sh
