require 'dotenv'
require 'pry'
require 'nest_thermostat'

Dotenv.load
RSpec.configure do |c|
    c.filter_run focus: true
    c.run_all_when_everything_filtered = true
end

describe NestThermostat::Nest do
  before(:all) do
    @nest = NestThermostat::Nest.new({email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'], temperature_scale: 'F'})
    @initial_temp = @nest.devices.first.temperature
    @initial_fan = @nest.devices.first.fan_mode
  end

  after(:all) do
    @nest.temperature = @initial_temp
    @nest.fan_mode = @initial_fan
  end

  it "logs in to home.nest.com" do
    @nest.transport_url.should match /transport(.*?).nest.com/
  end

  it "detects invalid logins" do
    expect { NestThermostat::Nest.new({email: 'invalid@example.com', password: 'asdf'})
    }.to raise_error
  end

  it "gets the status" do
    @nest.status['device'].first[1]['mac_address'].should match /(\d|[a-f]|[A-F])+/
  end

  it "gets the pubic ip address" do
    @nest.devices.first.public_ip.should match /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
  end

  it "gets the leaf status" do
    @nest.devices.first.leaf.should_not be_nil
  end

  it "gets away status" do
    @nest.structures.first.away.should_not be_nil
  end

  it "sets away status" do
    @nest.structures.first.away = true
    @nest.refresh
    @nest.structures.first.away.should == true
    @nest.structures.first.away = false
    @nest.refresh
    @nest.structures.first.away.should == false
  end

  it "gets the current temperature" do
    @nest.devices.first.current_temperature.should be_a_kind_of(Numeric)
    @nest.devices.first.current_temp.should be_a_kind_of(Numeric)
  end

  it "gets the relative humidity" do
    @nest.devices.first.humidity.should be_a_kind_of(Numeric)
  end

  it "gets the temperature" do
    @nest.devices.first.temperature.should be_a_kind_of(Numeric)
    @nest.devices.first.temp.should be_a_kind_of(Numeric)
  end

  it "sets the temperature" do
    @nest.devices.first.temp = '74'
    @nest.refresh
    @nest.devices.first.temp.round.should eq(74)

    @nest.devices.first.temperature = '73'
    @nest.refresh
    @nest.devices.first.temperature.round.should eq(73)
  end

  it "sets the temperature for entire structure" do
    @nest.structures.first.temp = '74'
    @nest.refresh
    @nest.structures.first.devices.each do |d|
      d.temp.round.should eq(74)
    end
    @nest.structures.first.temp = '72'
    @nest.refresh
    @nest.structures.first.devices.each do |d|
      d.temp.round.should eq(72)
    end
  end

  it "sets the temperature for entire account" do
    @nest.temp = '74'
    @nest.refresh
    @nest.devices.each do |d|
      d.temp.round.should eq(74)
    end
    @nest.temp = '72'
    @nest.refresh
    @nest.devices.each do |d|
      d.temp.round.should eq(72)
    end
  end

  it "sets the temperature in celsius" do
    @nest.temperature_scale = 'c'
    @nest.devices.first.temperature = '22'
    @nest.refresh
    @nest.devices.first.temperature.should eq(22.0)
  end

  it "sets the temperature in kelvin" do
    @nest.temp_scale = 'k'
    @nest.devices.first.temperature = '296'
    @nest.refresh
    @nest.devices.first.temperature.should eq(296.0)
  end

  it "gets the target temperature time" do
    @nest.devices.first.target_temp_at.should_not be_nil # (DateObject or false)
    @nest.devices.first.target_temperature_at.should_not be_nil # (DateObject or false)
  end

  it "gets the fan status" do
    %w(on auto).should include @nest.devices.first.fan_mode
  end

  it "sets the fan mode" do
    @nest.devices.first.fan_mode = "on"
    @nest.refresh
    @nest.devices.first.fan_mode.should == "on"
    @nest.devices.first.fan_mode = "auto"
    @nest.refresh
    @nest.devices.first.fan_mode.should == "auto"
  end

end
