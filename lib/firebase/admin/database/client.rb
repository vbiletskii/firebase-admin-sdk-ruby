# frozen_string_literal: true

require "json"
require "uri"
require_relative "../internal/http_client"
require_relative "error"
require_relative "response"
require_relative "server_value"

module Firebase
  module Admin
    module Database
      # A minimal Firebase Realtime Database REST API client.
      #
      # REST API reference: https://firebase.google.com/docs/reference/rest/database/
      class Client
        def initialize(app)
          @app = app
          @http_client = Firebase::Admin::Internal::HTTPClient.new(uri: base_uri, credentials: app.credentials)
        end

        # Reads data at the given path.
        #
        # @param [String] path A database path (no leading slash required)
        # @param [Hash] query Query options supported by the REST API (e.g. orderBy, limitToFirst, shallow, etc.)
        # @param [String,nil] etag If supplied, sent as If-Match for conditional reads.
        # @return [Response]
        def get(path, query: {}, etag: nil)
          headers = etag ? {"If-Match" => etag} : nil
          res = @http_client.get(url_with_query(path, query), nil, headers)
          Response.new(res)
        end

        # Writes data to the given path (replaces any existing data).
        #
        # @param [String] path
        # @param [Object] data JSON-serializable payload
        # @param [Hash] query Query options supported by the REST API (e.g. print, format)
        # @param [String,nil] etag If supplied, sent as If-Match for conditional writes.
        # @return [Response]
        def set(path, data, query: {}, etag: nil)
          headers = etag ? {"If-Match" => etag} : nil
          res = @http_client.put(url_with_query(path, query), JSON.generate(data), headers)
          Response.new(res)
        end

        # Pushes a new child node to the given path.
        #
        # @param [String] path
        # @param [Object] data
        # @param [Hash] query Query options supported by the REST API
        # @return [Response]
        def push(path, data, query: {})
          res = @http_client.post(url_with_query(path, query), data, nil)
          Response.new(res)
        end

        # Updates specific children at the given path.
        #
        # @param [String] path
        # @param [Hash] data
        # @param [Hash] query Query options supported by the REST API
        # @param [String,nil] etag If supplied, sent as If-Match for conditional writes.
        # @return [Response]
        def update(path, data, query: {}, etag: nil)
          raise Firebase::Admin::ArgumentError, "data must be a Hash" unless data.is_a?(Hash)
          headers = etag ? {"If-Match" => etag} : nil
          res = @http_client.patch(url_with_query(path, query), JSON.generate(data), headers)
          Response.new(res)
        end

        # Deletes data at the given path.
        #
        # @param [String] path
        # @param [Hash] query Query options supported by the REST API
        # @param [String,nil] etag If supplied, sent as If-Match for conditional deletes.
        # @return [Response]
        def delete(path, query: {}, etag: nil)
          headers = etag ? {"If-Match" => etag} : nil
          res = @http_client.delete(url_with_query(path, query), nil, headers)
          Response.new(res)
        end

        private

        def base_uri
          url = @app.database_url
          unless url.is_a?(String) && !url.empty?
            raise ConfigurationError, "Missing database_url. Set it in FIREBASE_CONFIG (databaseURL) or Config#database_url."
          end
          url
        end

        def url_for(path)
          normalized = path.to_s.sub(%r{\A/+}, "")
          normalized = "" if normalized == "/"
          normalized.empty? ? ".json" : "#{normalized}.json"
        end

        def url_with_query(path, query)
          url = url_for(path)
          q = normalize_query(query)
          return url if q.nil? || q.empty?
          "#{url}?#{URI.encode_www_form(q)}"
        end

        # Firebase REST query params like orderBy/startAt/endAt/equalTo must be JSON encoded.
        def normalize_query(query)
          return nil if query.nil? || query.empty?
          raise ArgumentError, "query must be a Hash" unless query.is_a?(Hash)

          json_keys = %i[orderBy startAt endAt equalTo]
          query.each_with_object({}) do |(k, v), acc|
            key = k.to_s
            acc[key] = json_keys.include?(k.to_sym) ? JSON.generate(v) : v
          end
        end
      end
    end
  end
end

module Firebase
  module Admin
    class App
      # Gets the Firebase Realtime Database client for this App.
      # @return [Firebase::Admin::Database::Client]
      def database
        @database_client ||= Database::Client.new(self)
      end
    end
  end
end


