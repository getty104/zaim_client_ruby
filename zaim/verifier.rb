# frozen_string_literal: true

require 'oauth'
require 'json'

module Zaim
  class Verifier
    private attr_reader :request_token

    def initialize(consumer_key:, consumer_secret:, oauth_callback:)
      consumer = OAuth::Consumer.new(
        consumer_key,
        consumer_secret,
        site: 'https://api.zaim.net',
        request_token_path: '/v2/auth/request',
        authorize_url: 'https://auth.zaim.net/users/auth',
        access_token_path: '/v2/auth/access'
      )
      @request_token = consumer.get_request_token(oauth_callback:)
    end

    def authorize_url
      request_token.authorize_url
    end

    def get_access_token(oauth_verifier:)
      access_token = request_token.get_access_token(oauth_verifier:)
      {
        access_key: access_token.token,
        access_secret: access_token.secret
      }
    end
  end
end
