# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class SessionsController < Arkaan::Utils::Controller

  load_errors_from __FILE__

  # @see https://github.com/jdr-tools/wiki/wiki/Sessions-API#creation-of-a-session
  declare_premium_route('post', '/') do
    check_presence 'username', 'password'

    account = Arkaan::Account.where(username: params['username']).first
    password = params['password']

    if account.nil?
      custom_error 404, 'username', 'unknown'
    elsif BCrypt::Password.new(account.password_digest) != password
      custom_error 403, 'password', 'wrong'
    else
      session = account.sessions.create(token: SecureRandom.hex)
      halt 201, Decorators::Session.new(session).to_json
    end
  end

  # @see https://github.com/jdr-tools/wiki/wiki/Sessions-API#getting-a-session
  declare_premium_route('get', '/:id') do
    session = Arkaan::Authentication::Session.where(token: params['id']).first

    if session.nil?
      custom_error 404, 'session_id', 'unknown'
    else
      halt 200, Decorators::Session.new(session).to_json
    end
  end

  # @see https://github.com/jdr-tools/wiki/wiki/Sessions-API#deleting-a-session
  declare_premium_route('delete', '/:id') do
    session = Arkaan::Authentication::Session.where(token: params['id']).first

    if session.nil?
      custom_error 404, 'session_id', 'unknown', suffix: '-1'
    else
      session.delete
      halt 200, {message: 'deleted'}.to_json
    end
  end
end
