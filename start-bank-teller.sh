#!/bin/bash
cd /src;
source /home/app/perl5/perlbrew/etc/bashrc
source envfile.sh
perl script/daemon/BankTeller start -f 1>>/data/log/bankteller.log 2>>/data/log/bankteller.error.log
