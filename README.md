# Nest Thermostat

This gem allows you to get and set the temperature of your [Nest Thermostat](https://nest.com/thermostat/life-with-nest-thermostat). You can also get and set the away status and get the current temperature and target temperature time.


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
nest = NestThermostat::Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'])
puts nest.current_temperature   # => 75.00
puts nest.current_temp          # => 75.00
puts nest.temperature           # => 73.00
puts nest.temp                  # => 73.00
puts nest.target_temperature_at # => 2012-06-05 14:28:48 +0000 # Ruby date object or false
puts nest.target_temp_at        # => 2012-06-05 14:28:48 +0000 # Ruby date object or false
puts nest.away                  # => false
puts nest.leaf                  # => true # May take a few seconds after a temp change
puts nest.humidity              # => 54 # Relative humidity in percent
```

Change the temperature or away status:
```ruby
puts nest.temperature # => 73.0
puts nest.temperature = 74.0
puts nest.temperature # => 74.0

puts nest.away # => false
puts nest.away = true
puts nest.away # => true
```

By default, temperatures are in `:fahrenheit`, but you can change this to `:celsius` or `:kelvin`:
```ruby
nest = NestThermostat::Nest.new(..., temperature_scale: :celsius)

# -- OR --

nest.temperature_scale = :kelvin
```

And of course if you want to get *lots* of other goodies, like scheduling and every diag piece of info you'd ever want:
```ruby
p nest.status

# -- OR --

require 'yaml'
yaml nest.status

# -- OR my favorite --

require 'ap' # gem install awesome_print
ap nest.status
```
Feel free to implement anything you see useful and submit a pull request. I'd love to see other information like scheduling or multiple device/location support added.


## Alfred Extension

If you use Alfred.app for OS X you may be interested in an extension. [Download it](http://erc.bz/HtOe). You'll need Ruby 1.9+ and this gem installed. Then just enter your nest email/pass as the arguments in the alfred extension (after you import it).

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
