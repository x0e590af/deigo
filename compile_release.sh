#!/bin/bash

rm -rf  ./_build/default/rel

rebar3 release

##\cp config/vm.args.tpl config/vm.args

ERL_FLAGS="-config app.config"

export RELX_REPLACE_OS_VARS=true

export NODE_NAME=node1@host1
export COOKIE_NAME=wwwww
export PORT=9999

./_build/default/rel/deigo/bin/deigo  console