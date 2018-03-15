#!/bin/bash

rm -rf  ./_build/

rebar3 as release tar

sh ./_build/release/rel/deigo/bin/deigo_client.sh  console