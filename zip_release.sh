#!/bin/bash

rebar3 as release tar

if [ -n "$1" ]; then
    mv ./_build/release/rel/deigo/deigo-$1.tar.gz ../deigo_release

else
    echo "useage:  $0 [tag_version]"
fi

