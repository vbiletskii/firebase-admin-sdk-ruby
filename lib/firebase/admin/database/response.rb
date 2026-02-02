module Firebase
  module Admin
    module Database
      # Wraps a Faraday response from the Realtime Database REST API.
      class Response
        # @return [Integer]
        attr_reader :code

        # @return [Hash]
        attr_reader :headers

        # @return [Object]
        attr_reader :body

        # @return [String]
        attr_reader :raw_body

        def initialize(response)
          @code = response.status
          @headers = response.headers || {}
          @body = response.body
          @raw_body = @body.is_a?(String) ? @body : JSON.generate(@body)
        end

        # @return [Boolean]
        def success?
          (200..299).include?(@code)
        end

        # @return [String, nil]
        def etag
          @headers["etag"] || @headers["ETag"]
        end
      end
    end
  end
end


