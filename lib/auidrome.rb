# Copyright 2015 The Cocktail Experience
module Auidrome
  ACTIONS_PER_PAGE = 3
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


  # Templates to build HREFs and other embeddings
  PROPERTY_VALUE_TEMPLATES = {
    hrefs: {
      twitter: "http://twitter.com/{{value}}",
      flickr: "http://www.flickr.com/photos/{{value}}",
      github: "http://github.com/{{value}}",
      soundcloud: "https://soundcloud.com/{{value}}"
    },
    embeddings: {
      audio: %!<p><em>({{value}})</em></p><iframe src="https://archive.org/embed/{{value}}" width="600" height="30" frameborder="0" webkitallowfullscreen="true" mozallowfullscreen="true" allowfullscreen></iframe>!,
      vimeo: %!<iframe src="https://player.vimeo.com/video/{{value}}" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>!,
      youtube: %!<iframe width="560" height="315" src="https://www.youtube.com/embed/{{value}}" frameborder="0" allowfullscreen></iframe>!
    }
  }
end
require_relative 'auidrome/config.rb'
require_relative 'auidrome/tuit.rb'
require_relative 'auidrome/drome.rb'
require_relative 'auidrome/people.rb'
require_relative 'auidrome/access_level.rb'
require_relative 'auidrome/search.rb'
require_relative 'auidrome/neo4j.rb'
