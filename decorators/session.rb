# frozen_string_literal: true

module Decorators
  # A session holds the informations about a user's connection on a device.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Session < Virtuatable::Enhancers::Base
    enhances Arkaan::Authentication::Session

    # Returns the session as an exploitable hash of key/value pairs.
    # @return [Hash<Symbol, String>] the hash representation of the session
    def to_h
      {
        token: token,
        created_at: created_at.utc.iso8601,
        account_id: account.id.to_s
      }
    end
  end
end
