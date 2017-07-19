#!/bin/bash
export PIDFILE=/tmp/start_server.pid

if [ -e "$PIDFILE" ]; then
    kill -HUP $(cat $PIDFILE)
fi

