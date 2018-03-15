#!/bin/bash

rm -rf  ./_build/default/rel

rebar3 as release tar

\cp config/sys.config.tpl config/sys.config
\cp config/vm.args.tpl config/vm.args

ERL_FLAGS="-config app.config"

export RELX_REPLACE_OS_VARS=true

export NODE_NAME=node1@host1
export COOKIE_NAME=deigocookie
export PORT=9527

./_build/release/rel/deigo/bin/deigo  console