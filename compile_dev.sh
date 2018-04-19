#!/bin/bash


#export RELX_REPLACE_OS_VARS=true
#export DEBUG=1
#export NODE_NAME=node1@host1
#export COOKIE_NAME=cookiedeigo
#export PORT=9999


rm -rf  ./_build/dev/rel/


rebar3 as dev tar


sh ./_build/dev/rel/deigo/bin/deigo  console