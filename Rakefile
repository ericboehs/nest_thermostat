#!/usr/bin/env rake
require "bundler/gem_tasks"


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  warn "RSpec is not available. Have you ran `bundle install`?"
end
