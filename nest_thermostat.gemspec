# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nest_thermostat/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Boehs"]
  gem.email         = ["ericboehs@gmail.com"]
  gem.description   = %q{Control your nest thermostat}
  gem.summary       = %q{View and set temperature and away status for your Nest}
  gem.homepage      = "http://github.com/ericboehs/nest_thermostat"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nest_thermostat"
  gem.require_paths = ["lib"]
  gem.version       = NestThermostat::VERSION
  gem.add_dependency "httparty", "~> 0.8.3"

  gem.add_development_dependency "rspec", "~> 3.1"
  gem.add_development_dependency "awesome_print"
  gem.add_development_dependency "dotenv"
  gem.add_development_dependency "pry"
end
