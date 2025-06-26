#!/bin/sh
eval `dbus export quarkdrivewebdav`
source /koolshare/scripts/base.sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
LOG_FILE=/tmp/upload/quarkdrivewebdavconfig.log
rm -rf $LOG_FILE
BIN=/koolshare/bin/quarkdrive-webdav
http_response "$1"

case $2 in
1)
    echo_date "当前已进入quarkdrivewebdav_config.sh" >> $LOG_FILE
    sh /koolshare/scripts/quarkdrivewebdavconfig.sh restart
    echo BBABBBBC >> $LOG_FILE
    ;;
esac
