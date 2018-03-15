#!/bin/bash


if [ -n "$1" ]; then

    git pull
    git add -A .
    git commit -m "$1"
    git push

else
    echo "useage:  $0 [desc]"
fi

