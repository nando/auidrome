# Copyright 2015 The Cocktail Experience
module Auidrome
  TUITS_PER_PAGE = 50
  TUITS_FILE = 'public/tuits.json'
  EMBER_FILE = 'public/auidos/js/auidrome.js'
  PUBLIC_TUITS_DIR = 'public/tuits'
  PEDALERS_DIR = 'data/public/pedalodrome/tuits'
  PROTECTED_TUITS_DIR = 'data/protected/auidrome/tuits'
  PRIVATE_TUITS_DIR = 'data/private/auidrome/tuits'
  CORE_PROPERTIES = %i(@id @context auido created_at identity madrino)
  HREF_PROPERTIES = %i{
    email
    web
    page
    blog
    photo
    video
    code
    sound
    media
    status
    linkedin
    wikipedia
    featuring
    tel.
  }
  # Protocols to build HREFs ('http://' if omitted)
  PROTOCOLS = {
    :email  => 'mailto:',
    :'tel.' => 'tel:'
  }
  # Templates to build HREFs
  PROPERTY_VALUE_TEMPLATES = {
    twitter: "http://twitter.com/{{value}}",
    flickr: "http://www.flickr.com/photos/{{value}}",
    github: "http://github.com/{{value}}"
  }

end
require_relative 'auidrome/config.rb'
require_relative 'auidrome/tuit.rb'
require_relative 'auidrome/drome.rb'
require_relative 'auidrome/people.rb'
require_relative 'auidrome/access_level.rb'
require_relative 'auidrome/search.rb'
