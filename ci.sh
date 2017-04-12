#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ~/perl5/perlbrew/etc/bashrc
cd $DIR
echo "doing cpanm --installdeps on $DIR"
cpanm Module::Install::Catalyst App::Sqitch App::ForkProve -n
cpanm -n --installdeps .
sqitch deploy -t $1
TRACE=1 forkprove -MLibre -j 1  -lvr t/
