require 'oauth'
require 'uri'

module Flickr
  class Login
    DEFAULTS = {
      site: "http://www.flickr.com/services",
      return_to: "/"
    }

    def initialize(api_key, shared_secret, options = {})
      @api_key, @shared_secret = api_key, shared_secret
      @options = DEFAULTS.merge(options)
    end

    def call(env)
      request = Request.new(env)

      unless request[:oauth_verifier]
        redirect_to_flickr(request)
      else
        handle_flickr_authorization(request)
      end
    end

    def login_handler(options = {})
      @options.update(options)
      self
    end

    module Helpers
      def flickr_user
        session[:flickr_user]
      end

      def flickr_access_token
        session[:flickr_access_token]
      end

      def flickr_clear
        [:flickr_user, :flickr_access_token].each do |key|
          session.delete(key)
        end
      end
    end

    class Request < ::Rack::Request
      def url_for(path)
        url = scheme + '://' + host
        if (scheme == 'https' and port != 443) or (scheme == 'http' and port != 80)
          url << ":#{port}"
        end
        url << path
      end
    end

    private

    def redirect_to_flickr(request)
      callback_url = URI.parse(request.url).tap { |url| url.query = nil }
      request_token = consumer.get_request_token(oauth_callback: callback_url.to_s)
      request.session[:flickr_request_token] = [request_token.token, request_token.secret]
      authorize_params = request[:perms] ? {perms: request[:perms]} : {}
      redirect request_token.authorize_url(authorize_params)
    end

    def handle_flickr_authorization(request)
      request_token = renew_request_token(request)
      access_token = request_token.get_access_token(oauth_verifier: request[:oauth_verifier])
      request.session[:flickr_access_token] = [access_token.token, access_token.secret]
      request.session[:flickr_user] = access_token.params
      redirect request.url_for(@options[:return_to])
    end

    def renew_request_token(request)
      rtoken, rsecret = request.session.delete(:flickr_request_token)
      OAuth::RequestToken.new(consumer, rtoken, rsecret)
    end

    def consumer
      @consumer ||= OAuth::Consumer.new @api_key, @shared_secret, site: @options[:site]
    end

    def redirect(url)
      ['302', {'Location' => url, 'Content-type' => 'text/plain'}, []]
    end
  end
end
