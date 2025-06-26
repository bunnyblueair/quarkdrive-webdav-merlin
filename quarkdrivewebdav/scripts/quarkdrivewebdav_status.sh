#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export quarkdrivewebdav_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

pid_ali=$(pidof quarkdrive-webdav)
date=$(echo_date)

if [ -n "$pid_ali" ]; then
    text1="<span style='color: #6C0'>$date 夸克网盘 进程运行正常！(PID: $pid_ali)</span>"
else
    text1="<span style='color: red'>$date 夸克网盘 进程未在运行！</span>"
fi

aliversion=$(/koolshare/bin/quarkdrive-webdav -V 2>/dev/null | head -n 1 | cut -d " " -f2)
if [ -n "$aliversion" ]; then
	aliversion="$aliversion"
else
	aliversion="null"
fi
dbus set quarkdrivewebdav_version="$aliversion"

http_response "$text1@$aliversion@"
