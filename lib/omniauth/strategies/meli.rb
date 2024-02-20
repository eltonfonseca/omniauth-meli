# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Omniauth strategy for authenticating with GitHub via OAuth2
    class Meli < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: 'https://api.mercadolibre.com',
        authorize_url: 'https://auth.mercadolibre.com.ar/authorization',
        token_url: 'https://api.mercadolibre.com/oauth/token'
      }

      uid { raw_info['id'].to_s }

      info do
        {
          nickname: raw_info['nickname'],
          email: raw_info['email']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/users/me').parsed || {}
      end
    end
  end
end

OmniAuth.config.add_camelization 'meli', 'Meli'
