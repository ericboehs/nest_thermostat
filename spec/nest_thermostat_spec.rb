require 'spec_helper'

module NestThermostat
  describe Nest do
    before(:all) do
      @nest = Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'], temperature_scale: :fahrenheit)
    end

    it "logs in to home.nest.com" do
      expect(@nest.transport_url).to match(/transport\.(home\.)?nest\.com/)
    end

    it "detects invalid logins" do
      expect {
        Nest.new({email: 'invalid@example.com', password: 'asdf'})
      }.to raise_error
    end

    it "does not remember the login email or password" do
      nest = Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'], temperature_scale: :fahrenheit)

      expect(nest).not_to respond_to(:email)
      expect(nest).not_to respond_to(:password)
    end

    it "gets the status" do
      expect(@nest.status['device'].first[1]['mac_address']).to match(/(\d|[a-f]|[A-F])+/)
    end

    it "gets the pubic ip address" do
      expect(@nest.public_ip).to match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/)
    end

    it "gets the leaf status" do
      expect(@nest.leaf?).to_not be_nil
    end

    it "gets away status" do
      expect(@nest.away?).to_not be_nil
    end

    it "sets away status" do
      @nest.away = true
      expect(@nest.away?).to be(true)
      @nest.away = false
      expect(@nest.away?).to be(false)
    end

    it "gets the current temperature" do
      expect(@nest.current_temperature).to be_a_kind_of(Numeric)
      expect(@nest.current_temp).to be_a_kind_of(Numeric)
    end

    it "gets the relative humidity" do
      expect(@nest.humidity).to be_a_kind_of(Numeric)
    end

    it "gets the temperature" do
      expect(@nest.temperature).to be_a_kind_of(Numeric)
      expect(@nest.temp).to be_a_kind_of(Numeric)
    end

    it "gets the low temperature" do
      expect(@nest.temperature_low).to be_a_kind_of(Numeric)
      expect(@nest.temp_low).to be_a_kind_of(Numeric)
    end

    it "gets the high temperature" do
      expect(@nest.temperature_high).to be_a_kind_of(Numeric)
      expect(@nest.temp_high).to be_a_kind_of(Numeric)
    end

    it "sets the temperature" do
      @nest.temp = '74'
      expect(@nest.temp.round).to eq(74)

      @nest.temperature = '73'
      expect(@nest.temperature).to eq(73)
    end

    it "sets the low temperature" do
      @nest.temp_low = '73'
      expect(@nest.temp_low.round).to eq(73)

      @nest.temperature_low = '74'
      expect(@nest.temperature_low.round).to eq(74)
    end

    it "sets the high temperature" do
      @nest.temp_high = '73'
      expect(@nest.temp_high.round).to eq(73)

      @nest.temperature_high = '74'
      expect(@nest.temperature_high.round).to eq(74)
    end

    it "sets the temperature in celsius" do
      @nest.temperature_scale = :celsius
      @nest.temperature = '22'
      expect(@nest.temperature).to eq(22.0)
    end

    it "sets the temperature in kelvin" do
      @nest.temp_scale = :kelvin
      @nest.temperature = '296'
      expect(@nest.temperature).to eq(296.0)
    end

    it "gets the target temperature time" do
      expect(@nest.target_temp_at).to_not be_nil # (DateObject or false)
      expect(@nest.target_temperature_at).to_not be_nil # (DateObject or false)
    end

    it "gets the fan status" do
      expect(%w[on auto]).to include(@nest.fan_mode)
    end

    it "sets the fan mode" do
      @nest.fan_mode = "on"
      expect(@nest.fan_mode).to eq("on")
      @nest.fan_mode = "auto"
      expect(@nest.fan_mode).to eq("auto")
    end

    it "gets the alt heat state" do
      expect(@nest.alt_heat_state).to_not be_nil
    end

    it "gets the main heat state" do
      expect(@nest.main_heat_state).to_not be_nil
    end

    it "gets the main AC state" do
      expect(@nest.main_ac_state).to_not be_nil
    end

    it "gets the target temperature type" do
      expect(%w[heat cool]).to include(@nest.target_temp_type)
    end
  end
end
