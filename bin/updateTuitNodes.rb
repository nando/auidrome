#!/usr/bin/env ruby
require './lib/auidrome.rb'
Auidrome::Drome.update_graph_nodes! Auidrome::Config.new(ARGV[0])
