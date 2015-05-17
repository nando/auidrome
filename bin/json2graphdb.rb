#!/usr/bin/env ruby
require './lib/auidrome.rb'
dromename = ARGV[0]
conf = Auidrome::Config.new(dromename)
Auidrome::Drome.update_graph_nodes! conf 
Auidrome::Drome.update_graph_relationships! conf
