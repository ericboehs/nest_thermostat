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
    @nest = NestThermostat::Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'], temperature_scale: 'F')
  end

  it "logs in to home.nest.com" do
    expect(@nest.transport_url).to match(/transport\.nest\.com/)
  end

  it "detects invalid logins" do
    expect {
      NestThermostat::Nest.new({email: 'invalid@example.com', password: 'asdf'})
    }.to raise_error
  end

  it "gets the status" do
    expect(@nest.status['device'].first[1]['mac_address']).to match(/(\d|[a-f]|[A-F])+/)
  end

  it "gets the pubic ip address" do
    expect(@nest.public_ip).to match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/)
  end

  it "gets the leaf status" do
    expect(@nest.leaf).to_not be_nil
  end

  it "gets away status" do
    expect(@nest.away).to_not be_nil
  end

  it "sets away status" do
    @nest.away = true
    expect(@nest.away).to be(true)
    @nest.away = false
    expect(@nest.away).to be(false)
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

  it "sets the temperature" do
    @nest.temp = '74'
    expect(@nest.temp.round).to eq(74)

    @nest.temperature = '73'
    expect(@nest.temperature).to eq(73)
  end

  it "sets the temperature in celsius" do
    @nest.temperature_scale = 'c'
    @nest.temperature = '22'
    expect(@nest.temperature).to eq(22.0)
  end

  it "sets the temperature in kelvin" do
    @nest.temp_scale = 'k'
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

end
