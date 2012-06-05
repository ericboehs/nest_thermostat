# NestThermostat

This gem allows you to get and set the temperature of your Nest
thermostat. You can also get and set the away status and get the
current temperature and target temperature time.

## Installation

Add this line to your application's Gemfile:

    gem 'nest_thermostat'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nest_thermostat

## Usage
Get some useful info:
```ruby
@nest = NestThermostat::Nest.new({email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS']})
puts @nest.current_temperature   # => 75.00
puts @nest.current_temp          # => 75.00
puts @nest.temperature           # => 73.00
puts @nest.temp                  # => 73.00
puts @nest.target_temperature_at # => 2012-06-05 14:28:48 +0000 # Ruby date object or false
puts @nest.target_temp_at        # => 2012-06-05 14:28:48 +0000 # Ruby date object or false
puts @nest.away                  # => false
puts @nest.leaf                  # => true # May take a few seconds after a temp change
puts @nest.humidity              # => 54 # Relative humidity in percent
```

Change the temperature or away status:
```ruby
puts @nest.temperature # => 73.0
puts @nest.temperature = 74.0
puts @nest.temperature # => 74.0

puts @nest.away # => false
puts @nest.away = true
puts @nest.away # => true
```

Default temperatures are in fahrenheit but you can change to celsius or kelvin:
```ruby
@nest = NestThermostat::Nest.new({..., temperature_scale: 'c'}) # Or C, Celsius or celsius

# -- OR --

@nest.temperature_scale = 'k' # or K, Kelvin or kelvin
```

And of course if you want to get LOTS of other goodies like (schedule and every diag piece of info you'd ever want):
```ruby
p @nest.status

# -- OR --

require 'yaml'
yaml @nest.status

# -- OR my favorite --

require 'ap' # gem install awesome_print
ap @nest.status
```
Feel free to implement anything you see useful and submit a pull
request. I'd love to see other information like scheduling or multiple
device/location support added.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
