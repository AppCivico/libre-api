#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ~/perl5/perlbrew/etc/bashrc
cd $DIR
echo "doing cpanm --installdeps on $DIR"
cpanm Module::Install::Catalyst App::Sqitch App::ForkProve -n
sqitch deploy -t local
cpanm -n --installdeps .
TRACE=1 forkprove -MLibre -j 1  -lvr t/
