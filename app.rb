# Copyright 2015 The Cocktail Experience, S.L.
require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'rack/cors'
require 'rack-flash'
require 'rack/session/cookie'
require 'omniauth-twitter'
require 'pry'
require 'json'
require 'stream'
require 'neo4j'
require_relative 'lib/auidrome'

EM.run do
  class App < Sinatra::Base
    include Auidrome
    use Rack::Logger

    set :bind, '0.0.0.0'

    def self.base_domain
      @@base_domain ||= ENV['RACK_ENV'] == 'production' ? ENV['AUIDROME_DOMAIN'] : 'localhost'
    end

    def self.config
      @@config ||= Config.new(ARGV[0], base_domain)
    end

    use Rack::Session::Cookie,
      :key => 'rack.session',
      :domain => App.base_domain,
      :path => '/',
      :expire_after => 3600, # In seconds
      :secret => ENV['CONSUMER_SECRET']
    use Rack::Flash

    use Rack::Cors do |config|
      config.allow do |allow|
        allow.origins '*'
        allow.resource '/auidos.json', headers: :any
      end
    end

    configure :production do
      raise "ENV[AUIDROME_DOMAIN] must be set in production" unless App.base_domain
    end

    configure do
      puts "AUIDROME: listening with #{App.config.site_name} in #{App.config.url}" + 
           " (looking to #{CardinalPoint.letter_to_word(App.config.cardinal_point.drift)})"

      if ActivityStream.configured?
        puts "Using AUIDROME_STREAM_ACTOR (#{ActivityStream.actor}), STREAM_KEY and STREAM_SECRET env. vars to StreamActivity."
      end

      if Neo4jServerDB.configured?
        puts "Using ENV[AUIDROME_NEO4J_SERVER] (#{Neo4jServerDB.server}) as graph DB server."
        Neo4jServerDB.start_session!
      end

      # Let the Ember.js app know where we are running
      File.open(EMBER_FILE,"w") do |f|
        f.write "auidrome_url = '#{App.config.url}';"
      end

      puts "Using ENV['CONSUMER_KEY'] and ENV['CONSUMER_SECRET'] for Twitter auth."
      use OmniAuth::Builder do
        provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
      end
      puts "Generating pretty JSON ;)" if App.config.pretty_json?
    end

    helpers do
      def logger
        request.logger
      end

      def current_user
        # e.g. "twitter/colgado" or "github/nando" (or nil)
        if session[:provider] && session[session[:provider]]
          "#{session[:provider]}/#{session[session[:provider]]}"
        end
      end

      def file_request?
        request.path_info =~ /\/(?:images)|(?:favicon\.ico$)/
      end

      def title
        @title ||= [
          App.config.site_name,
          @page_title || App.config.site_tagline
        ].join(': ')
      end

      def activity_page
        if @page && (@page > 0)
          "page #{@page}" + (@actions.any? ? " (#{@actions.first['tuit']}...)" : '.')
        else
          'Home'
        end
      end

      def activity_title
        @title ||= ActivityStream.error? ? ActivityStream.exception.message : activity_page
      end

      def me_or_by_me_button_text
        App.config.drome_of_humans? ? "It's me!" : "By me"
      end

      def amadrinate_or_authorship_button_text
        App.config.drome_of_humans? ? "Amadrinate" : "By others"
      end

      def pretty?
        App.config.pretty_json? || params[:pretty]
      end

      def referrer_could_be_a_property_value?
        request.referrer != request.url and
        request.referrer != App.config.url and
        (request.referrer =~ /\/better\//).nil? and (request.url =~ /\/better\//).nil? and
        (request.referrer =~ /\/search\?/).nil?
      end

      def get_port_from_referrer 
        if referrer_could_be_a_property_value?
          $1 if request.referrer and request.referrer =~ /:(\d+)/
        end
      end

      def get_value_from_referrer
        if referrer_could_be_a_property_value?
          CGI.unescape($1) if request.referrer and request.referrer =~ /\/([^\/]+)$/
        end
      end

      def error_span text
        %{<span class="error">ERROR: #{text}</span>}
      end

      def warning_span text
        %{<span class="warning">#{text}</span>}
      end

      def auido_title tuit
        if href = tuit.link_outside
          %{<a href="#{href}">#{tuit.auido}</a>}
        else
          tuit.auido
        end
      end
      
      def link_to_cardinal_drome(letter)
        cp = CardinalPoint.for_letter(letter)
        %|<a href="#{cp.drome_config.url}" title="#{cp.point}s" class="#{cp.point}_point">:#{cp.drome_config.emoji}:</a>|
      end

      def property_name_with_links(name)
        # Done thanks to Bozhidar Ivanov's post "Using Ruby's Gsub With a Block"
        #   (http://batsov.com/articles/2013/08/30/using-gsub-with-a-block/)
        name.to_s.gsub(/{{(.+)}}/) {
          human_auido = Regexp.last_match[1]
          if drome_config = Human.drome_config_for(human_auido)
            %!<a href="#{drome_config.url_for(human_auido)}">#{human_auido}</a>!
          else
            human_auido
          end
        } 
      end

      def show_property_name(name)
        # Done thanks to Bozhidar Ivanov's post "Using Ruby's Gsub With a Block"
        #   (http://batsov.com/articles/2013/08/30/using-gsub-with-a-block/)
        name.to_s.gsub(/{{(.+)}}/) {
          human_auido = Regexp.last_match[1]
          if drome_config = Human.drome_config_for(human_auido)
            %!<a href="#{drome.url}/tuits/#{human_auido}">#{human_auido}</a>!
          else
            human_auido
          end
        }
      end


    end

    before do
      logger.info "Proccessing #{request.path_info}?#{request.query_string}" unless file_request?
      pass unless request.path_info =~ /^\/admin/

      # /auth/twitter is captured by omniauth:
      # when the path info matches /auth/twitter, omniauth will redirect to twitter
      unless current_user
        session[:return_to] = request.path_info
        redirect to('/auth/twitter')
      end
    end

    def return_to path, message
      session[:return_to] = nil
      flash[:notice] = "───┤ #{message} ├───"
      redirect to(path || '/')
    end

    def read_tuit(auido)
      Tuit.new auido, App.config, current_user
    end

    def render_tuit_view image_quality
      @page_title = params[:auido]

      @tuit = read_tuit(params[:auido])
      @tuit_image = TuitImage.new(@tuit, image_quality)

      @property_to_drome = App.config.property_to_drome

      if port = get_port_from_referrer and
         dromename = Config.drome_for_port(port)
        @property_names_for_autocomplete = Config.properties_mapped_to(dromename).map {|p|
          {value: "#{p} => #{dromename}", data: p}
        }
      else
        @property_names_for_autocomplete = Config.properties_with_drome.map{|p, d|
          {value: "#{p} => #{d.dromename}", data: p}
        }
      end

      erb :tuit
    end

    def between_actions_fleuron
      '─'*17 + ' ❧❦☙  ' + '─'*17 # Nice idea from @fxn's Tkn. Thanks nen!
    end

    get '/auth/twitter/callback' do
      session[:uid] = env['omniauth.auth']['uid']
      session[:provider] = :twitter
      session[:twitter] = env['omniauth.auth']['info']['nickname']

      return_to session[:return_to], "Twitter session started as <strong>@#{session[:twitter]}</strong>."
    end

    get '/auth/failure' do
      return_to session[:return_to], "Sorry, something was wrong with your authentication. :("
    end

    get "/" do
      array = Tuit.stored_tuits.to_a
      size = array.length
      @pages = ((size - 1) / TUITS_PER_PAGE.to_f).to_i + 1
      @page = [[params[:page].to_i, 1].max, @pages].min
      from = size - TUITS_PER_PAGE * @page
      to = from + TUITS_PER_PAGE - 1
      tuits = array[([from, 0].max)..to]
      @tuits_submitted = Hash[tuits].invert.to_json
      erb :index
    end

    get "/auidos.json" do
      content_type :'application/json'
      Tuit.stored_tuits.map do |auido, timestring|
        {
          data: Time.parse(timestring).to_i,
          value: auido
        }
      end.to_json
    end

    post "/tuits" do
      piido = params[:piido].strip.to_sym
      logger.info (current_user || 'Somebody') + " has shouted: ¡¡¡#{piido}!!!"
      previously_stored = !Tuit.stored_tuits[piido].nil?
      App.config.create_tuit!(piido) unless previously_stored
      piido_link = %@<a href="/tuits/#{piido}">#{piido}</a>@
      if previously_stored
        msg = warning_span('We already knew ' + piido_link + ', thanks anyway!')
      else
        msg = piido_link + ' is now between us!'
      end
      return_to '/', msg
    end

    get "/tuits/:auido.json" do
      auido = params[:auido].to_sym
      if Tuit.exists? auido
        content_type :'application/json'
        tuit = read_tuit(auido)
        tuit.save_json! # if we're here then the JSON file is not there
        JSON.pretty_generate tuit.hash
      elsif App.config.drome_of_humans? and # i'm from the anti-if-campaign but
            human_drome = Human.drome_config_for(auido) # let's do this only for humans :D
        redirect to human_drome.url + request.path
      else
        raise Sinatra::NotFound
      end
    end

    get '/json-context.json' do
      content_type :'application/json'
      @ports = {}
      @properties = Config.properties_with_drome.inject({}) do |h, (k,v)|
        @ports[v.dromename] ||= v.port_base
        h[k] = v.dromename;
        h
      end

      yml = YAML.load_file('config/json_context.json.yml')
      yml['drome_name'] = App.config.site_name
      yml['drome_item_name'] = App.config.item_name
      yml['drome_item_description'] = App.config.item_description
      yml['living_things_drome'] = App.config.living_things_drome rescue false
      yml['dromes_ports'] = @ports
      yml['property_mappings'] = @properties

      pretty? ? JSON.pretty_generate(yml) : yml
    end

    # Search tuits with params[:query] in their auidos/names
    # For example:
    #   $ curl localhost:3003/search.json?query=ALEX
    get "/search.?:format?" do
      if @query = (params[:query]  || params[:piido]) and Auidrome::Search.searchable_text?(@query)
        search = Auidrome::Search.new(@query, App.config)
        if search.results.any?
          if params[:format] == 'json'
            content_type :'application/json'
            JSON.pretty_generate search.payload
          else
            @search_payload = search.payload.to_json
            erb :index
          end
        else
          raise Sinatra::NotFound
        end
      else
        raise Sinatra::NotFound
      end
    end

    get "/tuits/better/better/better/:auido" do
      render_tuit_view 3 
    end

    get "/tuits/better/better/:auido" do
      render_tuit_view 2 
    end

    get "/tuits/better/:auido" do
      render_tuit_view 1 
    end

    get "/tuits/:auido" do
      render_tuit_view 0 
    end

    get "/admin" do
      erb :admin
    end

    get "/admin/its-me/:auido" do
      auido = params['auido']
      tuit = read_tuit(auido)
      if tuit.identity.include? current_user
        msg = warning_span('Yes, we already knew that! :)')
      else
        tuit.add_identity! current_user 
        msg = "Added <strong>#{current_user}</strong> as identity/author of <strong>" + auido + '</strong>.'
      end
      return_to 'tuits/' + auido, msg
    end

    get "/admin/amadrinate/:auido" do
      auido = params['auido']
      tuit = read_tuit(auido)
      if tuit.madrino.include? current_user
        msg = warning_span('You already was madrino of <strong>' + auido + '</strong>')
      else
        tuit.add_madrino! current_user 
        msg = "Now you are a madrino of <strong>" + auido + '</strong>. GREAT!!!'
      end
      # ActivityStream.amadrinate! tuit
      return_to 'tuits/' + auido, msg
    end

    get "/activity" do
      if ActivityStream.configured?
        @page = [0, params[:page].to_i].max
        @actions = ActivityStream.get(@page)
        @next = ActivityStream.next
        if @actions.any?
          erb :activity, layout: :activity_layout
        else
          erb :activity_empty, layout: :activity_layout
        end
      else
        return_to '/', warning_span('ActivityStream has not been configured in this drome :(')
      end
    end

    post '/admin/property/:auido' do
      auido = params['auido'].to_sym
      property_name = params['property_name'].strip.to_sym
      value = params['property_value'].strip
      if property_name.empty?
        msg = error_span("No property name for '#{value}'.")
      elsif value.empty?
        msg = error_span("No value for property '#{property_name}'.")
      else
        App.config.create_tuit!(auido) unless Tuit.exists?(auido) # Right now then!
        tuit = read_tuit(auido)
        if tuit.properties.include? property_name
          msg = warning_span("One more value for #{auido}'s #{property_name}")
        else
          msg = "Now we know something about #{auido}'s #{property_name}"
        end
        #TODO: (IMPORTANT) check current_user rigths!!!
        tuit.add_value! property_name, value
      end
      return_to "tuits/#{auido}", msg
    end
  end

  @clients = []
  EM::WebSocket.start(:host => '0.0.0.0', :port => App.config.port_base + 1) do |ws|
    ws.onopen do |handshake|
      puts "WebSocket#onopen"
      @clients << ws
    end

    ws.onclose do
      puts "WebSocket#onclose"
      ws.send "Closed."
      @clients.delete ws
    end

    ws.onmessage do |auido|
      puts "WebSocket#onmessage: #{auido}"
      if Auidrome::Search.searchable_text? auido
        search = Auidrome::Search.new(auido, App.config)
        ws.send(search.payload.to_json)
      end
    end
  end

  App.run! :port => App.config.port_base
end
