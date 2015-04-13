#!/bin/bash
# Copyright 2015 The Cocktail Experience
source 'bin/dromeslib.sh'

if [ $# -eq 0 ]; then
  dromes=$DROME_NAMES
else
  dromes=$1
fi

for drome in $dromes; do
  run_command "cd ../$drome"
  run_command "cp public/tuits.json ../auidrome/data/public/$drome"
  run_command "cp public/tuits/* ../auidrome/data/public/$drome/tuits/"

  run_command "cp -Rf public/images/* data/public/$drome/images/"
  run_command "rm -Rf data/public/$drome/images/common"
  run_command "rm -Rf data/public/$drome/images/screenshots"
  #run_command "rm data/public/$drome/images/think.png"
  #run_command "rm data/public/$drome/images/shout.png"
  #if [ "$drome" != auidrome ]; then
  #  run_command "rm data/public/$drome/images/ARIEN.png"
  #  run_command "rm data/public/$drome/images/AURORA.png"
  #  run_command "rm data/public/$drome/images/IRIA.png"
  #  run_command "rm data/public/$drome/images/LUCAS.png"
  #  run_command "rm data/public/$drome/images/LUCASSH.png"
  #  run_command "rm data/public/$drome/images/MARCO.png"
  #  if [ "$drome" != acadodrome ]; then
  #    run_command "rm data/public/$drome/images/OLALLA.png"
  #  fi
  #  run_command "rm data/public/$drome/images/OLIVIA.png"
  #  run_command "rm data/public/$drome/images/@SUBSTACK.png"
  #fi

  #run_command "rm public/images/ARIEN.png"
  #run_command "rm public/images/AURORA.png"
  #run_command "rm public/images/IRIA.png"
  #run_command "rm public/images/LUCAS.png"
  #run_command "rm public/images/LUCASSH.png"
  #run_command "rm public/images/MARCO.png"
  #run_command "rm public/images/OLALLA.png"
  #run_command "rm public/images/OLIVIA.png"
  #run_command "rm public/images/PDMX-20140304.png"
  #run_command "rm public/images/@SUBSTACK.png"

  #run_command "rm data/public/$drome/images/frijolito.png"

  #run_command "rm data/public/$drome/images/acadodrome.png"
  #run_command "rm data/public/$drome/images/auidrome.png"
  #run_command "rm data/public/$drome/images/byebyedrome.png"
  #run_command "rm data/public/$drome/images/fictiondrome.png"
  #run_command "rm data/public/$drome/images/lovedrome.png"
  #run_command "rm data/public/$drome/images/pedalodrome.png"
  #run_command "rm data/public/$drome/images/repulsodrome.png"
  #run_command "rm data/public/$drome/images/restodrome.png"
  #run_command "rm data/public/$drome/images/ripodrome.png"

done







