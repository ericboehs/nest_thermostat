require 'nest_thermostat/nest/device'

module NestThermostat
  class Nest
    class Structure
      attr_accessor :nest, :id, :devices, :name

      def initialize(nest, id, config = {})
        self.nest = nest
        self.id = id
        self.name = config['name']
        self.devices = config['devices'].collect{|device_id| NestThermostat::Nest::Device.new(self, device_id.split('.')[1])}
      end

      def away
        status["away"]
      end

      def away=(state)
        nest.set_control_for_structure(self, %Q({"away_timestamp":#{Time.now.to_i},"away":#{!!state},"away_setter":0}))
      end


      def temperature=(degrees)
        devices.collect{|d| d.temperature = degrees}
      end
      alias_method :temp=, :temperature=


      def fan_mode=(state)
        devices.collect{|d| d.fan_mode = state}
      end

      private
      def status
        nest.status_for_structure(self)
      end

      def shared_status
        nest.status_for_shared(self)
      end
    end
  end
end