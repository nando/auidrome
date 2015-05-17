#!/bin/bash
# Copyright 2015 The Cocktail Experience
echo "Loading JSON files into the Neo4j DB (server => '$AUIDROME_NEO4J_SERVER')"
source 'bin/dromeslib.sh'

for drome in $DROME_NAMES; do
  echo 
  echo "Press [Enter] key to load the $drome JSONs' nodes and relationships..."
  ask_and_run "cd ../$drome && ./bin/json2graphdb.rb $drome"
done
