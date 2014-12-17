require 'nest_thermostat'
require 'dotenv'
require 'pry'

Dotenv.load

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end
