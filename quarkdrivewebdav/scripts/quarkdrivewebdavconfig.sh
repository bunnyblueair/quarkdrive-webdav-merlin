#!/bin/sh
eval `dbus export quarkdrivewebdav`
source /koolshare/scripts/base.sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
LOG_FILE=/tmp/upload/quarkdrivewebdavconfig.log
BIN=/koolshare/bin/quarkdrive-webdav

if [ "$(cat /proc/sys/vm/overcommit_memory)"x != "0"x ];then
    echo 0 > /proc/sys/vm/overcommit_memory
fi

quarkdrivewebdav_start_stop(){
    echo_date "当前已进入quarkdrivewebdavconfig.sh执行" >> $LOG_FILE
    if [ "${quarkdrivewebdav_enable}"x = "1"x ];then
        echo_date "先结束进程" >> $LOG_FILE
        killall quarkdrive-webdav
        EXTRA_ARGS=""
        if [ "${quarkdrivewebdav_auth_user}"x != ""x ];then
          EXTRA_ARGS="-U ${quarkdrivewebdav_auth_user}"
        fi
        if [ "${quarkdrivewebdav_auth_password}"x != ""x ];then
          EXTRA_ARGS="$EXTRA_ARGS -W ${quarkdrivewebdav_auth_password}"
        fi
        if [ "${quarkdrivewebdav_read_bufffer_size}"x = ""x ];then
          quarkdrivewebdav_read_bufffer_size="10485760"
        fi
        if [ "${quarkdrivewebdav_cache_size}"x = ""x ];then
          quarkdrivewebdav_cache_size="1000"
        fi
        if [ "${quarkdrivewebdav_root}"x = ""x ];then
          quarkdrivewebdav_root="/"
        fi
        if [ "${quarkdrivewebdav_redirect}"x = "1"x ];then
          EXTRA_ARGS="$EXTRA_ARGS --redirect"
        fi
        echo_date "参数为：${quarkdrivewebdav_port} --quark-cookie ${quarkdrivewebdav_refresh_token} --root ${quarkdrivewebdav_root} -S ${quarkdrivewebdav_read_buffer_size} --cache-size ${quarkdrivewebdav_cache_size} $EXTRA_ARGS" >> $LOG_FILE
        #start-stop-daemon -S -q -b -m -p ${PID_FILE} \
        #  -x /bin/sh -- -c "${BIN} -I --workdir /var/run/quarkdrivewebdav --host 0.0.0.0 -p ${quarkdrivewebdav_port} -r ${quarkdrivewebdav_refresh_token} --root ${quarkdrivewebdav_root} -S ${quarkdrivewebdav_read_bufffer_size} $EXTRA_ARGS >/tmp/quarkdrivewebdav.log 2>&1"
        ${BIN} -I --no-self-upgrade --workdir /var/run/quarkdrivewebdav --host 0.0.0.0 -p ${quarkdrivewebdav_port} --quark-cookie "${quarkdrivewebdav_refresh_token}" --root ${quarkdrivewebdav_root} -S ${quarkdrivewebdav_read_buffer_size} --cache-size ${quarkdrivewebdav_cache_size} $EXTRA_ARGS >/tmp/upload/quarkdrivewebdav.log 2>&1 &
        sleep 5s
        if [ ! -z "$(pidof quarkdrive-webdav)" -a ! -n "$(grep "Error" /tmp/upload/quarkdrivewebdav.log)" ] ; then
          echo_date "quarkdrive 进程启动成功！(PID: $(pidof quarkdrive-webdav))" >> $LOG_FILE
          if [ "$quarkdrivewebdav_public" == "1" ]; then
            iptables -I INPUT -p tcp --dport $quarkdrivewebdav_port -j ACCEPT >/dev/null 2>&1 &
          else
            iptables -D INPUT -p tcp --dport $quarkdrivewebdav_port -j ACCEPT >/dev/null 2>&1 &
          fi
        else
          echo_date "quarkdrive 进程启动失败！请检查参数是否存在问题，即将关闭" >> $LOG_FILE
          echo_date "失败原因：" >> $LOG_FILE
          error1=$(cat /tmp/upload/quarkdrivewebdav.log | grep -ioE "Error.*")
          if [ -n "$error1" ]; then
              echo_date $error1 >> $LOG_FILE
          fi
          dbus set quarkdrivewebdav_enable="0"
        fi
    else
        killall quarkdrive-webdav
        iptables -D INPUT -p tcp --dport $quarkdrivewebdav_port -j ACCEPT >/dev/null 2>&1 &
    fi
}
quarkdrivewebdav_stop(){
  killall quarkdrive-webdav
  iptables -D INPUT -p tcp --dport $quarkdrivewebdav_port -j ACCEPT >/dev/null 2>&1 &
}


case $ACTION in
start)
    quarkdrivewebdav_start_stop
    echo BBABBBBC >> $LOG_FILE
    ;;
start_nat)
    quarkdrivewebdav_start_stop
    echo BBABBBBC >> $LOG_FILE
    ;;
restart)
    quarkdrivewebdav_start_stop
    ;;
stop)
    quarkdrivewebdav_stop
    echo BBABBBBC >> $LOG_FILE
    ;;
*)
    quarkdrivewebdav_start_stop
    echo BBABBBBC >> $LOG_FILE
    ;;
esac
