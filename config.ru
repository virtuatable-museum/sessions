require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

micro_service = Arkaan::Utils::MicroService.new(name: 'sessions', root: File.dirname(__FILE__)).load!

map(micro_service.registered_service.path) { run SessionsController.new }
