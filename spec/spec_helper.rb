require "nest_thermostat"
require "dotenv"
require "pry"
require "fakeweb"
require "vcr"
require "timecop"
require "awesome_print"

Dotenv.load

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.extend VCR::RSpec::Macros
end

VCR.configure do |c|
  c.cassette_library_dir = "fixtures/vcr_cassettes"
  c.hook_into :fakeweb
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
end
