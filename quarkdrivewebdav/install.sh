#!/bin/sh
source /koolshare/scripts/base.sh
eval $(dbus export quarkdrivewebdav_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=$(nvram get productid)
MODULE=quarkdrivewebdav
DIR=$(cd $(dirname $0); pwd)
# 判断路由架构和平台
case $(uname -m) in
	aarch64)
		if [ -d "/koolshare" ];then
			echo_date 固件平台【koolshare merlin aarch64 / merlin_hnd】符合安装要求，开始安装插件！
		else
			echo_date 本插件适用于【koolshare merlin aarch64 / merlin_hnd】固件平台，你的平台不能安装！！！
			rm -rf /tmp/f3322* >/dev/null 2>&1
			exit 1
		fi
		;;
	armv7l)
		if [ -d "/koolshare" ] && ([ -n "`nvram get buildno|grep 384`" ] || [ -n "`nvram get buildno|grep 386`" ]);then
			echo_date 固件平台【koolshare merlin armv7l 384】符合安装要求，开始安装插件！
		else
			echo_date 本插件适用于【koolshare merlin armv7l 384】固件平台，你的固件平台不能安装！！！
			echo_date 退出安装！
			exit 1
		fi
		;;
	*)
		echo_date 本插件适用于koolshare merlin aarch64固件平台，你的平台：$(uname -m)不能安装！！！
		echo_date 退出安装！
		rm -rf /tmp/f3322* >/dev/null 2>&1
		exit 1
	;;
esac
if [ "$quarkdrivewebdav_enable" == "1" ];then
	echo_date 先关闭quarkdrivewebdav，保证文件更新成功!
	[ -f "/koolshare/scripts/quarkdrivewebdavconfig.sh" ] && sh /koolshare/scripts/quarkdrivewebdavconfig.sh stop >/dev/null 2>&1 &
fi
# 检测储存空间是否足够
echo_date 检测jffs分区剩余空间...
SPACE_AVAL=$(df|grep jffs|head -n 1  | awk '{print $4}')
SPACE_NEED=$(du -s /tmp/quarkdrivewebdav | awk '{print $1}')
if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
	echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 插件安装需要"$SPACE_NEED" KB，空间满足，继续安装！
	
    cd /tmp
    cp -rf /tmp/quarkdrivewebdav/bin/* /koolshare/bin/
    cp -rf /tmp/quarkdrivewebdav/scripts/* /koolshare/scripts/
    cp -rf /tmp/quarkdrivewebdav/webs/* /koolshare/webs/
    cp -rf /tmp/quarkdrivewebdav/res/* /koolshare/res/
    cp -rf /tmp/quarkdrivewebdav/uninstall.sh /koolshare/scripts/uninstall_quarkdrivewebdav.sh

    chmod 755 /koolshare/bin/quarkdrive-webdav
    chmod 755 /koolshare/scripts/quarkdriveweb*
	chmod 755 /koolshare/res/quarkdriveweb*
    chmod 755 /koolshare/scripts/uninstall_quarkdrivewebdav.sh
    ln -sf /koolshare/scripts/quarkdrivewebdavconfig.sh /koolshare/init.d/S99quarkdrivewebdav.sh

    dbus set softcenter_module_${MODULE}_name="${MODULE}"
    dbus set softcenter_module_${MODULE}_title="夸克网盘WebDAV"
    dbus set softcenter_module_${MODULE}_description="夸克网盘 WebDAV 服务器"
    dbus set softcenter_module_${MODULE}_version="$(cat $DIR/version)"
    dbus set softcenter_module_${MODULE}_install="1"

    # 默认配置
    dbus set ${MODULE}_port="8080"
    dbus set ${MODULE}_read_buffer_size="10485760"

    rm -rf /tmp/quarkdrivewebdav* >/dev/null 2>&1
    aw_enable=`dbus get quarkdrivewebdav_enable`
    if [ "${aw_enable}"x = "1"x ];then
        sh /koolshare/scripts/quarkdrivewebdav_config.sh 1 1 >/dev/null 2>&1 &
    fi
    logger "[软件中心]: 完成 quarkdrivewebdav 安装"
    exit
else
	echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 插件安装需要"$SPACE_NEED" KB，空间不足！
	echo_date 退出安装！
	exit 1
fi
