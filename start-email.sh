#!/bin/bash
cd /src;
source /home/app/perl5/perlbrew/etc/bashrc
source envfile.sh
perl script/daemon/Emailsd start -f 1>>/data/log/email.log 2>>/data/log/email.error.log
