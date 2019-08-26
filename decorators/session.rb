# frozen_string_literal: true

module Decorators
  # A session holds the informations about a user's connection on a device.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Session < Draper::Decorator
    delegate_all

    # Returns the session as an exploitable JSON object.
    # @return [String] a JSON object to display to the user.
    def to_json(*args)
      to_h.to_json(*args)
    end

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
