require 'bundler'
Bundler.require :test

require 'arkaan/specs'

service = Arkaan::Utils::MicroService.instance
  .register_as('sessions')
  .from_location(__FILE__)
  .in_test_mode

Arkaan::Specs.include_shared_examples