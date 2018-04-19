#!/bin/bash

status=prod
#workdir=$(cd $(dirname $0); pwd)


#export RELX_REPLACE_OS_VARS=true
#export NODE_NAME=node1@host1
#export COOKIE_NAME=cookiedeigo
#export PORT=9528


#export VMARGS_PATH="$workdir/_build/prod/rel/deigo/etc/vm.args"
#export RELX_CONFIG_PATH="$workdir/_build/prod/rel/deigo/etc/sys.config"


rm -rf  ./_build/$status/rel/

rebar3 as $status tar

sh ./_build/$status/rel/deigo/bin/deigo start