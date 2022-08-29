# frozen_string_literal: true

require 'json'
require 'oauth'
require 'uri'

module Zaim
  class Client
    API_URL = 'https://api.zaim.net'

    private attr_reader :access_token

    def initialize(consumer_key:, consumer_secret:, access_key:, access_secret:)
      consumer = OAuth::Consumer.new(
        consumer_key,
        consumer_secret,
        site: 'https://api.zaim.net',
        request_token_path: '/v2/auth/request',
        authorize_url: 'https://auth.zaim.net/users/auth',
        access_token_path: '/v2/auth/access'
      )

      @access_token = OAuth::AccessToken.new(consumer, access_key, access_secret)
    end

    def request(http_method:, endpoint:, params: {})
      unless %i(get post put delete patch).include?(http_method)
        raise NotPermittedValueError, 'Only :get, :post, :put, :delete, :patch are allowed for http_method'
      end

      uri = URI.parse("#{API_URL}#{endpoint}")
      uri.query = nil
      request_url = uri.to_s

      response = if %i(get delete).include?(http_method)
        formatted_params = params.map { |key, value| "#{key}=#{value}" }.join('&')
        request_url = "#{request_url}?#{formatted_params}" if formatted_params.present?
        access_token.get(request_url)
      else
        access_token.send(http_method, request_url, params)
      end

      JSON.parse(response.body, symbolize_names: true)
    end

    class NotPermittedValueError < StandardError; end
  end
end

