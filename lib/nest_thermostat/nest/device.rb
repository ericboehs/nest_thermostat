module NestThermostat
  class Nest
    class Device
      attr_accessor :structure, :id

      def initialize(structure, id, config = {})
        self.structure = structure
        self.id = id
      end

      def public_ip
        nest.status["track"][self.id]["last_ip"].strip
      end

      def leaf
        status["leaf"]
      end

      def humidity
        status["current_humidity"]
      end

      def current_temperature
        convert_temp_for_get(shared_status["current_temperature"])
      end
      alias_method :current_temp, :current_temperature

      def temperature
        convert_temp_for_get(shared_status["target_temperature"])
      end
      alias_method :temp, :temperature

      def temperature=(degrees)
        degrees = convert_temp_for_set(degrees)
        nest.set_control_for_shared(self, %Q({"target_change_pending":true,"target_temperature":#{degrees}}))
      end
      alias_method :temp=, :temperature=

      def target_temperature_at
        epoch = status["time_to_target"]
        epoch != 0 ? Time.at(epoch) : false
      end
      alias_method :target_temp_at, :target_temperature_at

      def fan_mode
        status["fan_mode"]
      end

      def fan_mode=(state)
        nest.set_control_for_device(self, %Q({"fan_mode":"#{state}"}))
      end

      private

      def nest
        structure.nest
      end

      def status
        nest.status_for_device(self)
      end

      def shared_status
        nest.status_for_shared(self)
      end

      def convert_temp_for_get(degrees)
        case nest.temperature_scale
        when /[fF](ahrenheit)?/
          c2f(degrees).round(3)
        when /[kK](elvin)?/
          c2k(degrees).round(3)
        else
          degrees
        end
      end

      def convert_temp_for_set(degrees)
        case nest.temperature_scale
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
end