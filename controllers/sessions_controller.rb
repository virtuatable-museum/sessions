# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class SessionsController < Arkaan::Utils::Controller

  # @see https://github.com/jdr-tools/wiki/wiki/Sessions-API#creation-of-a-session
  declare_premium_route('post', '/') do
    check_presence('username', 'password')

    account = Arkaan::Account.where(username: params['username']).first
    password = params['password']

    if account.nil?
      url = 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#account-not-found'
      halt 404, {status: 404, field: 'username', error: 'unknown', docs: url}.to_json
    elsif BCrypt::Password.new(account.password_digest) != password
      url = 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#password-not-matching'
      halt 403, {status: 403, field: 'password', error: 'wrong', docs: url}.to_json
    else
      session = account.sessions.create(token: SecureRandom.hex)
      halt 201, Decorators::Session.new(session).to_json
    end
  end

  # @see https://github.com/jdr-tools/wiki/wiki/Sessions-API#getting-a-session
  declare_premium_route('get', '/:id') do
    session = Arkaan::Authentication::Session.where(token: params['id']).first

    if session.nil?
      url = 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#session-not-found'
      halt 404, {status: 404, field: 'session_id', error: 'unknown', docs: url}.to_json
    else
      halt 200, Decorators::Session.new(session).to_json
    end
  end

  # @see https://github.com/jdr-tools/wiki/wiki/Sessions-API#deleting-a-session
  declare_premium_route('delete', '/:id') do
    session = Arkaan::Authentication::Session.where(token: params['id']).first

    if session.nil?
      url = 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#session-not-found-1'
      halt 404, {status: 404, field: 'session_id', error: 'unknown', docs: url}.to_json
    else
      session.delete
      halt 200, {message: 'deleted'}.to_json
    end
  end
end
