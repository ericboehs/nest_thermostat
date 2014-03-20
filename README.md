# Nest Thermostat

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
@nest.structures                      # => Array of all Structures NestThermostat::Nest::Structure
@nest.devices                         # => Array of all devices from all structures NestThermostat::Nest::Device
@device = @nest.devices.first
@structure = @nest.structures.first
puts @device.current_temperature      # => 75.00
puts @device.current_temp             # => 75.00
puts @device.temperature              # => 73.00
puts @device.temp                     # => 73.00
puts @device.target_temperature_at    # => 2012-06-05 14:28:48 +0000 # Ruby date object or false
puts @device.target_temp_at           # => 2012-06-05 14:28:48 +0000 # Ruby date object or false
puts @structure.away                  # => false
puts @device.leaf                     # => true # May take a few seconds after a temp change
puts @device.humidity                 # => 54 # Relative humidity in percent
```

Change the temperature or away status:
```ruby
# @nest changes for all structures and all devices if applicable
# @structure changes for all devices of the structure if applicable

puts @device.temperature # => 73.0
puts @device.temperature = 74.0
@nest.refresh
puts @device.temperature # => 74.0

puts @structure.away # => false
puts @structure.away = true
@nest.refresh
puts @structure.away # => true
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


## Alfred Extension

If you use Alfred.app for OS X you may be interested in an extension.
[Download it](http://erc.bz/HtOe). You'll need ruby 1.9+ and this gem
installed. Then just enter your nest email/pass as the arguments in the
alfred extension (after you import it).

![Screenshot of Alfred Extension](http://erc.bz/H9Hm/Image%202012.06.05%202:18:56%20PM.png) ![Screenshot of Alfred Extension Growl Output](http://erc.bz/H97m/Image%202012.06.05%202:34:49%20PM.png)


Here are the commands it supports:
```
nest          # => Your Nest is set to 73°F
nest 72       # => Your Nest was set to 72°F
nest current  # => The current temperature is currently 71.51°F
nest leaf     # => The leaf is off; you can fix that! (or: The leaf is on; you are energy efficient!)
nest away     # => Your Nest is now set to away (or: Your Nest is now set to home.)
nest home     # => Your Nest is now set to home
nest humidity # => The relative humidity is currently 53%
nest until    # => Your home will reach it's target temperature at 7:30pm
nest ip       # => The current ip address is 5.68.127.16. I placed it in your clipboard.
```

There are some aliases as well:
```
nest current | current temp | current temperature
nest home | back
nest leaf | green
nest until | til | time
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
