require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

Virtuatable::Application.load!('sessions')

run Controllers::Sessions