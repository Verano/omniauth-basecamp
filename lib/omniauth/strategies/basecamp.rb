require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Basecamp < OmniAuth::Strategies::OAuth2
      option :client_options,
             site: 'https://launchpad.37signals.com',
             authorize_url: '/authorization/new',
             token_url: '/authorization/token'

      def authorize_params
        super.tap do |params|
          params[:response_type] = 'code'
          params[:client_id] = client.id
          params[:redirect_uri] ||= callback_url
          params[:type] = 'web_server'
        end
      end

      uid do
        info[:id]
      end

      info do
        raw_info.fetch(:identity)
      end

      extra do
        raw_info
      end

      def build_access_token
        token_params = {
          code: request.params['code'],
          redirect_uri: callback_url,
          client_id: client.id,
          client_secret: client.secret,
          type: 'web_server'
        }
        client.get_token(token_params)
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.get('/authorization.json').parsed)
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
