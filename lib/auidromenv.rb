require './lib/auidrome.rb'
include Auidrome

Dir.entries('config/dromes').each do |filename|
  if filename =~ /([a-z]+)\.yml$/
    dromename = $1
    eval("@#{dromename} = Auidrome::Config.new(dromename)")
  end
end

def read_tuit auido, cfg = @auidrome
  Tuit.new auido, cfg
end
