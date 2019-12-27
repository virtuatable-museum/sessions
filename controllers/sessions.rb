# frozen_string_literal: true

module Controllers
  # Main controller of the application, creating and destroying sessions.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Sessions < Virtuatable::Controllers::Base

    api_route 'post', '/', options: { authenticated: false, premium: true } do
      check_presence 'email', 'password'

      account = Arkaan::Account.find_by(email: params['email'])
      api_not_found 'email.unknown' if account.nil?
      api_forbidden 'password.wrong' if matches_password(account)

      session = account.sessions.create(token: SecureRandom.hex)
      api_created session
    end

    api_route 'get', '/:id', options: { premium: true } do
      api_not_found 'session_id.unknown' if current_session.nil?
      api_item session
    end

    api_route 'delete', '/:id', options: { premium: true } do
      api_not_found 'session_id.unknown' if current_session.nil?
      session.delete
      api_ok 'deleted'
    end

    def current_session
      Arkaan::Authentication::Session.find_by(token: params['id'])
    end

    def matches_password(account)
      BCrypt::Password.new(account.password_digest) != params['password']
    end
  end
end
