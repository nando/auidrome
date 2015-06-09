#!/bin/bash
# Copyright 2015 The Cocktail Experience
echo "Loading current JSON files' relationships into the Neo4j DB at $AUIDROME_NEO4J_SERVER"
source 'bin/dromeslib.sh'
for drome in $DROME_NAMES; do
  run_command "cd ../$drome && ./bin/updateTuitRelationships.rb $drome"
done
