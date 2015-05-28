#!/bin/bash

function run {
  echo "Running '$1'..."
  cmd="$1"
  eval "$cmd"
  echo " => DONE!"
}

if [ $# -eq 2 ]; then
  drome=$1
  image=$(echo "$2" | sed -e "s/ /\\\ /g")
  target=otaony.com:\"dromes/$drome/public/images/"$image"\"
  run "scp $image $target"
else
  echo 'Usage: uploadphoto.sh DROME FILE'
fi
