#!/bin/bash
# Copyright 2015 The Cocktail Experience
echo "Loading JSON files into the Neo4j DB (at $AUIDROME_NEO4J_SERVER)"
source 'bin/dromeslib.sh'

for drome in $DROME_NAMES; do
  echo 
  echo "Press [Enter] key to load the $drome nodes..."
  ask_and_run "cd ../$drome && ./bin/updateTuitNodes.rb $drome"
done

for drome in $DROME_NAMES; do
  echo 
  echo "Press [Enter] key to load the $drome relationships..."
  ask_and_run "cd ../$drome && ./bin/updateTuitRelationships.rb $drome"
done
