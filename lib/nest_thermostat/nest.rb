require 'rubygems'
require 'httparty'
require 'json'
require 'uri'

module NestThermostat
  class Nest
    attr_accessor :login_url, :user_agent, :auth, :login, :token, :user_id,
    :transport_url, :transport_host, :structure_id, :device_id, :headers

    attr_reader :temperature_scale

    def initialize(config = {})
      raise 'Please specify your nest email'    unless config[:email]
      raise 'Please specify your nest password' unless config[:password]

      # User specified information
      self.temperature_scale = config[:temperature_scale] || config[:temp_scale] || :fahrenheit
      @login_url  = config[:login_url] || 'https://home.nest.com/user/login'
      @user_agent = config[:user_agent] ||'Nest/1.1.0.10 CFNetwork/548.0.4'

      # Login and get token, user_id and URLs
      perform_login(config[:email], config[:password])

      @token          = @auth["access_token"]
      @user_id        = @auth["userid"]
      @transport_url  = @auth["urls"]["transport_url"]
      @transport_host = URI.parse(@transport_url).host
      @headers = {
        'Host'                  => self.transport_host,
        'User-Agent'            => self.user_agent,
        'Authorization'         => 'Basic ' + self.token,
        'X-nl-user-id'          => self.user_id,
        'X-nl-protocol-version' => '1',
        'Accept-Language'       => 'en-us',
        'Connection'            => 'keep-alive',
        'Accept'                => '*/*'
      }

      # Set device and structure id
      status
    end

    def status
      request = HTTParty.get("#{self.transport_url}/v2/mobile/user.#{self.user_id}", headers: self.headers)
      result = JSON.parse(request.body)

      structures = result['user'][user_id]['structures']
      if structures.any?
        self.structure_id = structures.first.split('.')[1]
      end

      if self.structure_id
        devices = result['structure'][structure_id]['devices']
        if devices.any?
          self.device_id = devices.first.split('.')[1]
        end
      end

      result
    end

    def public_ip
      last_ip = track["last_ip"]

      # TODO: Should return something better than empty string here?
      last_ip ? last_ip.strip : ""
    end

    def leaf?
      device["leaf"]
    end

    def humidity
      device["current_humidity"]
    end

    def current_temperature
      convert_temp_for_get(shared["current_temperature"])
    end
    alias_method :current_temp, :current_temperature

    def temperature
      convert_temp_for_get(shared["target_temperature"])
    end
    alias_method :temp, :temperature

    def temperature_low
      convert_temp_for_get(shared["target_temperature_low"])
    end
    alias_method :temp_low, :temperature_low

    def temperature_high
      convert_temp_for_get(shared["target_temperature_high"])
    end
    alias_method :temp_high, :temperature_high

    def temperature=(degrees)
      degrees = convert_temp_for_set(degrees)

      post_to_shared_api(target_change_pending: true, target_temperature: degrees);
    end
    alias_method :temp=, :temperature=

    def temperature_low=(degrees)
      degrees = convert_temp_for_set(degrees)

      post_to_shared_api(target_change_pending: true, target_temperature_low: degrees);
    end
    alias_method :temp_low=, :temperature_low=

    def temperature_high=(degrees)
      degrees = convert_temp_for_set(degrees)

      post_to_shared_api(target_change_pending: true, target_temperature_high: degrees)
    end
    alias_method :temp_high=, :temperature_high=

    def target_temperature_at
      epoch = device["time_to_target"]
      epoch != 0 ? Time.at(epoch) : false
    end
    alias_method :target_temp_at, :target_temperature_at

    def away?
      structure["away"]
    end

    def away=(state)
      post_to_structure_api(away_timestamp: Time.now.to_i, away: !!state, away_setter: 0)
    end

    def temperature_scale=(scale)
      if %i[kelvin celsius fahrenheit].include?(scale)
        @temperature_scale = scale
      else
        raise ArgumentError, "#{scale} is not a valid temperature scale"
      end
    end
    alias_method :temp_scale=, :temperature_scale=

    def fan_mode
      device["fan_mode"]
    end

    def fan_mode=(state)
      post_to_device_api(fan_mode: state)
    end

    def method_missing(name, *args, &block)
      if %i[away leaf].include?(name)
        warn "`#{name}' has been replaced with `#{name}?'. Support for " +
        "`#{name}' without the '?' will be dropped in future versions."
        return self.send("#{name}?", *args)
      end

      super
    end

    private

    def perform_login(email, password)
      login_request = HTTParty.post(
      self.login_url,
      body:    { username: email, password: password },
      headers: { 'User-Agent' => self.user_agent }
      )

      @auth ||= JSON.parse(login_request.body)
      raise 'Invalid login credentials' if auth.has_key?('error') && @auth['error'] == "access_denied"
    end

    def convert_temp_for_get(degrees)
      case @temperature_scale
      when :fahrenheit then c2f(degrees).round(5)
      when :kelvin     then c2k(degrees).round(5)
      when :celsius    then degrees
      end
    end

    def convert_temp_for_set(degrees)
      case @temperature_scale
      when :fahrenheit then f2c(degrees).round(5)
      when :kelvin     then k2c(degrees).round(5)
      when :celsius    then degrees.to_f
      end
    end

    def k2c(degrees)
      degrees.to_f - 273.15
    end

    def c2k(degrees)
      degrees.to_f + 273.15
    end

    def c2f(degrees)
      degrees.to_f * 9.0 / 5 + 32
    end

    def f2c(degrees)
      (degrees.to_f - 32) * 5 / 9
    end

    def post_to_shared_api(body)
      HTTParty.post("#{self.transport_url}/v2/put/shared.#{self.device_id}",
                    body: body.to_json,
                    headers: self.headers)
    end

    def post_to_device_api(body)
      HTTParty.post("#{self.transport_url}/v2/put/device.#{self.device_id}",
                    body: body.to_json,
                    headers: self.headers)
    end

    def post_to_structure_api(body)
      HTTParty.post("#{self.transport_url}/v2/put/structure.#{self.structure_id}",
                    body: body.to_json,
                    headers: self.headers)
    end

    def status_data(key, id)
      # Try to get the status data based on device_id, otherwise return empty status data
      status.fetch(key, {}).fetch(id, {})
    end

    def structure
      status_data("structure", self.structure_id)
    end

    def shared
      status_data("shared", self.device_id)
    end

    def device
      status_data("device", self.device_id)
    end

    def track
      status_data("track", self.device_id)
    end
  end
end
