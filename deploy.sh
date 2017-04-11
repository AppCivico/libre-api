#!/bin/bash
GIT_DIR=$(git rev-parse --show-toplevel)

if [ -f $GIT_DIR/envfile.sh ]; then
    source $GIT_DIR/envfile.sh
fi

STARMAN_BIN="$(which starman)"
DAEMON="$(which start_server)"

line (){
    perl -e "print '-' x 40, $/";
}

mkdir -p $GIT_DIR/log/

up_server (){
    PSGI_APP_NAME="$1"
    PORT="$2"
    WORKERS="$3"

    ERROR_LOG="$GIT_DIR/log/libre.error.log"
    STATUS="$GIT_DIR/log/libre.start_server.status"
    PIDFILE="$GIT_DIR/log/libre.start_server.pid"

    touch $ERROR_LOG
    touch $PIDFILE
    touch $STATUS

    STARMAN="$STARMAN_BIN -I$GIT_DIR/lib --preload-app --error-log=$ERROR_LOG --workers $WORKERS $GIT_DIR/$PSGI_APP_NAME"

    DAEMON_ARGS=" --pid-file=$PIDFILE --signal-on-hup=QUIT --status-file=$STATUS --port $PORT -- $STARMAN"

    echo STDERR "Restarting...  $DAEMON --restart $DAEMON_ARGS"
    $DAEMON --restart $DAEMON_ARGS

    if [ $? -gt 0 ]; then
        echo STDERR "Restart failed, application likely not running. Starting..."

        echo STDERR "/sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS"
        /sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS

        if [ $? -gt 0 ]; then
            echo STDERR "Start failed again... starting in foreground";

            /sbin/start-stop-daemon --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS
        fi
    fi
}

cpanm . --installdeps

sqitch deploy -t $SQITCH_DEPLOY

export DBIC_TRACE=0

echo STDERR "Restaring server...";
up_server "libre.psgi" $API_PORT $API_WORKERS

line

# Daemons.
./script/daemon/Emailsd restart
./script/daemon/Emailsd status

