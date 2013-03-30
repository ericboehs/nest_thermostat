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
  end

  it "logs in to home.nest.com" do
    @nest.transport_url.should match /transport.nest.com/
  end

  it "detects invalid logins" do
    expect { NestThermostat::Nest.new({email: 'invalid@example.com', password: 'asdf'})
    }.to raise_error
  end

  it "gets the status" do
    @nest.status['device'].first[1]['mac_address'].should match /(\d|[a-f]|[A-F])+/
  end

  it "gets the pubic ip address" do
    @nest.public_ip.should match /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
  end

  it "gets the leaf status" do
    @nest.leaf.should_not be_nil
  end

  it "gets away status" do
    @nest.away.should_not be_nil
  end

  it "sets away status" do
    @nest.away = true
    @nest.away.should == true
    @nest.away = false
    @nest.away.should == false
  end

  it "gets the current temperature" do
    @nest.current_temperature.should be_a_kind_of(Numeric)
    @nest.current_temp.should be_a_kind_of(Numeric)
  end

  it "gets the relative humidity" do
    @nest.humidity.should be_a_kind_of(Numeric)
  end

  it "gets the temperature" do
    @nest.temperature.should be_a_kind_of(Numeric)
    @nest.temp.should be_a_kind_of(Numeric)
  end

  it "sets the temperature" do
    @nest.temp = '74'
    @nest.temp.round.should eq(74)

    @nest.temperature = '73'
    @nest.temperature.round.should eq(73)
  end

  it "sets the temperature in celsius" do
    @nest.temperature_scale = 'c'
    @nest.temperature = '22'
    @nest.temperature.should eq(22.0)
  end

  it "sets the temperature in kelvin" do
    @nest.temp_scale = 'k'
    @nest.temperature = '296'
    @nest.temperature.should eq(296.0)
  end

  it "gets the target temperature time" do
    @nest.target_temp_at.should_not be_nil # (DateObject or false)
    @nest.target_temperature_at.should_not be_nil # (DateObject or false)
  end
end
