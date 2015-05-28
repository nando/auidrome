#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'dromeslib.sh'

if [ $# -eq 1 ]; then
  echo "Updating only $1"
  DROME_NAMES=$1
fi

for drome in $DROME_NAMES; do
  if [ $drome == "auidrome" ]
  then
    echo "'auidrome' drome, skipping..."
    continue
  fi
  run_command "cd ../$drome"
  run_command "cp ../auidrome/public/images/common/* public/images/common/"
  run_command "cp ../auidrome/public/css/* public/css/"
  run_command "cp ../auidrome/public/js/* public/js/"
done
