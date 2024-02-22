# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Omniauth strategy for authenticating with GitHub via OAuth2
    class Meli < OmniAuth::Strategies::OAuth2
      option :name, 'mercadolivre'

      option :client_options, {
        site: 'https://api.mercadolibre.com',
        authorize_url: 'https://auth.mercadolivre.com.br/authorization',
        token_url: 'https://api.mercadolibre.com/oauth/token'
      }

      uid { raw_info['id'].to_s }

      info do
        deep_compact!(
          {
            nickname: raw_info['nickname'],
            email: raw_info['email'],
            first_name: raw_info['first_name'],
            last_name: raw_info['last_name'],
            image: raw_info['logo'],
            url: raw_info['permalink']
          }
        )
      end

      extra do
        hash = {}
        hash[:access_token] = access_token.to_hash
        hash[:raw_info] = raw_info unless skip_info?
        deep_compact! hash
      end

      def authorize_params
        super.tap do |params|
          params[:response_type] = 'code'
          params[:client_id] = client.id
          params[:redirect_uri] = callback_url.to_s.downcase
        end
      end

      def build_access_token
        client.get_token(
          {
            code: request.params['code'],
            redirect_uri: callback_url.to_s.downcase,
            client_id: client.id,
            client_secret: client.secret,
            grant_type: 'authorization_code'
          }
        )
      end

      def raw_info
        @raw_info ||= access_token.get('users/me', { params: access_token.hash }).parsed || {}
      end

      private

      def deep_compact!(hash)
        hash.delete_if do |_, value|
          deep_compact!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'meli', 'Meli'
