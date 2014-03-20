require 'nest_thermostat/nest/structure'

require 'rubygems'
require 'httparty'
require 'json'
require 'uri'

module NestThermostat
  class Nest
    attr_accessor :email, :password, :login_url, :user_agent, :auth,
      :temperature_scale, :login, :token, :user_id, :transport_url,
      :transport_host, :structures, :headers

    def initialize(config = {})
      raise 'Please specify your nest email'    unless config[:email]
      raise 'Please specify your nest password' unless config[:password]

      # User specified information
      self.email             = config[:email]
      self.password          = config[:password]
      self.temperature_scale = config[:temperature_scale] || config[:temp_scale] || 'f'
      self.login_url         = config[:login_url] || 'https://home.nest.com/user/login'
      self.user_agent        = config[:user_agent] ||'Nest/1.1.0.10 CFNetwork/548.0.4'
      self.structures        = []

      # Login and get token, user_id and URLs
      set_session_variables

      # Set devices and structures
      @status = get_status(true)
    end

    def devices
      self.structures.collect(&:devices).flatten
    end

    def auth
      @auth ||= perform_login
    end

    def temp_scale=(scale)
      self.temperature_scale = scale
    end

    def status
      @status ||= get_status(false)
    end

    def refresh
      set_session_variables && (@status = get_status(true))
    end

    def away=(state)
      structures.collect{|s| s.away = state }
    end

    def temperature=(degrees)
      structures.collect{|s| s.temperature = degrees}
    end
    alias_method :temp=, :temperature=


    def fan_mode=(state)
      structures.collect{|s| s.fan_mode = state}
    end

    def set_control_for(control_type, item, message)
      request = HTTParty.post(
        "#{self.transport_url}/v2/put/#{control_type}.#{item.id}",
        body: message,
        headers: self.headers
      ) rescue nil
    end

    def status_for(status_type, item = nil)
      item ? self.status[status_type][item.id] : self.status[status_type]

    end

    def method_missing(method, *args, &block)
      #set_control_for
      if control_type = method.to_s.match(/set_control_for_(.*)?/)
        self.set_control_for(control_type[1], *args)
      elsif status_type = method.to_s.match(/status_for_(.*)?/)
        self.status_for(status_type[1], *args)
      else
        super
      end
    end

    private
    def perform_login
      login_request = HTTParty.post(
                        self.login_url,
                        body:    { username: self.email, password: self.password },
                        headers: { 'User-Agent' => self.user_agent }
                      )
      auth_response = JSON.parse(login_request.body) rescue nil
      raise 'Invalid login credentials' if auth_response.has_key?('error') && auth_response['error'] == "access_denied"
      return auth_response
    end

    def set_session_variables
      self.token          = self.auth["access_token"]
      self.user_id        = self.auth["userid"]
      self.transport_url  = self.auth["urls"]["transport_url"]
      self.transport_host = URI.parse(self.transport_url).host
      self.headers = {
        'Host'                  => self.transport_host,
        'User-Agent'            => self.user_agent,
        'Authorization'         => 'Basic ' + self.token,
        'X-nl-user-id'          => self.user_id,
        'X-nl-protocol-version' => '1',
        'Accept-Language'       => 'en-us',
        'Connection'            => 'keep-alive',
        'Accept'                => '*/*'
      }
    end

    def get_status(reload_structures = true)
      request = HTTParty.get("#{self.transport_url}/v2/mobile/user.#{self.user_id}", headers: self.headers) rescue nil
      result = JSON.parse(request.body) rescue nil

      if reload_structures
        self.structures = result['structure'].collect{|structure_id, config| Structure.new(self, structure_id, config)}
      end

      result
    end
  end
end
