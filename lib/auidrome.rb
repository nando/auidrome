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
  CORE_PROPERTIES = %i(@id @context auido transliterated created_at updated_at identity madrino json_url filename)
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
      soundcloud: "https://soundcloud.com/{{value}}",
      instagram: "https://instagram.com/{{value}}/"
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
require_relative 'auidrome/tuit_image.rb'
require_relative 'auidrome/drome.rb'
require_relative 'auidrome/access_level.rb'
require_relative 'auidrome/search.rb'
require_relative 'auidrome/neo4j.rb'

require_relative 'auidrome/cardinal_point.rb'
require_relative 'auidrome/human.rb'
require_relative 'auidrome/document.rb'

## Copyright / License

Copyright 2015 The Cocktail Experience, S.L.

Licensed under the GNU General Public License Version 3.0 (or later); you may not use this work except in compliance with the License. You may obtain a copy of the License in the COPYING file, or at:

http://www.gnu.org/licenses/gpl-3.0.txt

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
