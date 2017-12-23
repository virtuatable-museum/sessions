# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class SessionsController < Sinatra::Base

  post '/' do
    @parameters = JSON.parse(request.body.read.to_s) rescue {}

    if @parameters['token'].nil? || @parameters['username'].nil? || @parameters['password'].nil? || @parameters['app_key'].nil?
      halt 400, {message: 'bad_request'}.to_json
    else
      gateway = Arkaan::Monitoring::Gateway.where(token: @parameters['token']).first
      application = Arkaan::OAuth::Application.where(key: @parameters['app_key']).first
      account = Arkaan::Account.where(username: @parameters['username']).first
      password = @parameters['password']

      if application.nil?
        halt 404, {message: 'application_not_found'}.to_json
      elsif !application.premium?
        halt 401, {message: 'application_not_authorized'}.to_json
      elsif gateway.nil?
        halt 404, {message: 'gateway_not_found'}.to_json
      elsif account.nil?
        halt 404, {message: 'account_not_found'}.to_json
      elsif BCrypt::Password.new(account.password_digest) != password
        halt 403, {message: 'wrong_password'}.to_json
      else
        expiration = @parameters['expiration'] || 3600
        session = account.sessions.create(token: SecureRandom.hex, expiration: expiration)
        halt 201, Decorators::Session.new(session).to_json
      end
    end
  end

  get '/:id' do
    if params['token'].nil? || params['app_key'].nil?
      halt 400, {message: 'bad_request'}.to_json
    else
      gateway = Arkaan::Monitoring::Gateway.where(token: params['token']).first
      application = Arkaan::OAuth::Application.where(key: params['app_key']).first
      session = Arkaan::Authentication::Session.where(token: params['id']).first

      if application.nil?
        halt 404, {message: 'application_not_found'}.to_json
      elsif !application.premium?
        halt 401, {message: 'application_not_authorized'}.to_json
      elsif gateway.nil?
        halt 404, {message: 'gateway_not_found'}.to_json
      elsif session.nil?
        halt 404, {message: 'session_not_found'}.to_json
      else
        halt 200, Decorators::Session.new(session).to_json
      end
    end
  end
end
