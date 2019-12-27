require 'bundler'
Bundler.require :test

Virtuatable::Application.load_tests!('sessions')