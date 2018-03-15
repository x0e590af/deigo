#!/usr/bin/env bash

workdir=$(cd $(dirname $0); pwd)


source $workdir/../conf/default.sh


if [ -n "$1" ]; then

    $workdir/deigo $1

else
    $workdir/deigo
fi
