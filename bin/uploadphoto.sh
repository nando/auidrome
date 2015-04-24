#!/bin/bash

if [ $# -eq 2 ]; then
  drome=$1
  image=$2

  echo "scp $image otaony.com:dromes/$drome/public/images/$image"
  scp       $image otaony.com:dromes/$drome/public/images/$image
else
  echo 'Usage: uploadphoto.sh DROME FILE'
fi
