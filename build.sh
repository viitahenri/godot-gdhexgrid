#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1
fi
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

mkdir build/$1
godot --no-window --export HTML5 build/$1/index.html
sh sync-s3.sh
echo "http://hexhexhex.eu-north-1.amazonaws.com/$1/index.html"
