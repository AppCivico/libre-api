#!/bin/bash
export PIDFILE=/tmp/start_server.pid;

cd /src;
source /home/app/perl5/perlbrew/etc/bashrc;
source envfile.sh;

sqitch deploy -t $SQITCH_DEPLOY

if [ -e "$PIDFILE" ]; then
    kill -HUP $(cat $PIDFILE)
fi

./script/daemon/Emailsd stop -f;
