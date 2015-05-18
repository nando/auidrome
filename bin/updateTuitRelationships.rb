#!/usr/bin/env ruby
require './lib/auidrome.rb'
Auidrome::Drome.update_graph_relationships! Auidrome::Config.new(ARGV[0])
