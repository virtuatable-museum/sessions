require 'bundler'
Bundler.require :test

Arkaan::Utils::MicroService.new(name: 'sessions', root: File.dirname(__FILE__), test_mode: true).load!