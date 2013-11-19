require 'rubygems'
require 'httparty'
require 'json'
require 'uri'

module NestThermostat
  class Nest
    attr_accessor :email, :password, :login_url, :user_agent, :auth,
      :temperature_scale, :login, :token, :user_id, :transport_url,
      :transport_host, :structure_id, :device_id, :headers, :names

    def initialize(config = {})
      raise 'Please specify your nest email'    unless config[:email]
      raise 'Please specify your nest password' unless config[:password]

      # User specified information
      self.email             = config[:email]
      self.password          = config[:password]
      self.temperature_scale = config[:temperature_scale] || config[:temp_scale] || 'f'
      self.login_url         = config[:login_url] || 'https://home.nest.com/user/login'
      self.user_agent        = config[:user_agent] ||'Nest/1.1.0.10 CFNetwork/548.0.4'

      # Login and get token, user_id and URLs
      perform_login
      self.token          = @auth["access_token"]
      self.user_id        = @auth["userid"]
      self.transport_url  = @auth["urls"]["transport_url"]
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

      # Set device and structure id
      self.names = Hash.new
      self.device = 0
      status
    end

    def status
      request = HTTParty.get("#{self.transport_url}/v2/mobile/user.#{self.user_id}", headers: self.headers) rescue nil
      result = JSON.parse(request.body) rescue nil

      self.structure_id = result['user'][user_id]['structures'][0].split('.')[1]
      
      result["shared"].each {|device, value| names[value['name']] = device } 
      result
    end

    def device=(device)
      if device.class == String
        self.device_id = self.names[device]
      else
        self.device_id    = status['structure'][structure_id]['devices'][device].split('.')[1]
      end
    end

    def public_ip
      status["track"][self.device_id]["last_ip"].strip
    end

    def leaf
      status["device"][self.device_id]["leaf"]
    end

    def humidity
      status["device"][self.device_id]["current_humidity"]
    end

    def current_temperature
      convert_temp_for_get(status["shared"][self.device_id]["current_temperature"])
    end
    alias_method :current_temp, :current_temperature

    def temperature
      convert_temp_for_get(status["shared"][self.device_id]["target_temperature"])
    end
    alias_method :temp, :temperature

    def temperature=(degrees)
      degrees = convert_temp_for_set(degrees)

      request = HTTParty.post(
        "#{self.transport_url}/v2/put/shared.#{self.device_id}",
        body: %Q({"target_change_pending":true,"target_temperature":#{degrees}}),
        headers: self.headers
      ) rescue nil
    end
    alias_method :temp=, :temperature=

    def set_temperature(degrees,name=self.names.keys.first)
      degrees = convert_temp_for_set(degrees)

      request = HTTParty.post(
        "#{self.transport_url}/v2/put/shared.#{self.names[name]}",
        body: %Q({"target_change_pending":true,"target_temperature":#{degrees}}),
        headers: self.headers
      ) rescue nil
    end


    def target_temperature_at
      epoch = status["device"][self.device_id]["time_to_target"]
      epoch != 0 ? Time.at(epoch) : false
    end
    alias_method :target_temp_at, :target_temperature_at

    def away
      status["structure"][structure_id]["away"]
    end

    def away=(state)
      request = HTTParty.post(
        "#{self.transport_url}/v2/put/structure.#{self.structure_id}",
        body: %Q({"away_timestamp":#{Time.now.to_i},"away":#{!!state},"away_setter":0}),
        headers: self.headers
      ) rescue nil
    end

    def temp_scale=(scale)
      self.temperature_scale = scale
    end

    def fan_mode
      status["device"][self.device_id]["fan_mode"]
    end

    def fan_mode=(state)
      HTTParty.post(
        "#{self.transport_url}/v2/put/device.#{self.device_id}",
        body: %Q({"fan_mode":"#{state}"}),
        headers: self.headers
      ) rescue nil
    end

    # def name
    #   status["device"][@nest.device_id]["name"]
    # end

    private
    def perform_login
      login_request = HTTParty.post(
                        self.login_url,
                        body:    { username: self.email, password: self.password },
                        headers: { 'User-Agent' => self.user_agent }
                      )

      self.auth ||= JSON.parse(login_request.body) rescue nil
      raise 'Invalid login credentials' if self.auth.has_key?('error') && self.auth['error'] == "access_denied"
    end

    def convert_temp_for_get(degrees)
      case self.temperature_scale
      when /[fF](ahrenheit)?/
        c2f(degrees).round(3)
      when /[kK](elvin)?/
        c2k(degrees).round(3)
      else
        degrees
      end
    end

    def convert_temp_for_set(degrees)
      case self.temperature_scale
      when /[fF](ahrenheit)?/
        f2c(degrees).round(5)
      when /[kK](elvin)?/
        k2c(degrees).round(5)
      else
        degrees
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
  end
end
