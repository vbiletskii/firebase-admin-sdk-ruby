require "jwt"

module Firebase
  module Admin
    module Auth
      # Generates Firebase Custom Tokens using service account credentials.
      class CustomTokenGenerator
        GOOGLE_AUDIENCE = "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit"

        # @param [Firebase::Admin::App] app
        def initialize(app)
          @app = app
          @credentials_wrapper = app.credentials
          @google_credentials = if @credentials_wrapper.respond_to?(:credentials)
            @credentials_wrapper.credentials
          else
            @credentials_wrapper
          end
        end

        # Creates a signed custom token for the given uid and optional custom claims.
        #
        # @param [String] uid The user id for which to create a token.
        # @param [Hash,nil] claims Optional custom claims to include under the 'claims' key.
        # @return [String] The signed JWT.
        def create_custom_token(uid, claims = nil)
          raise ArgumentError, "uid must be a non-empty string" unless uid.is_a?(String) && !uid.empty?

          issuer = if @google_credentials.respond_to?(:issuer)
            @google_credentials.issuer
          elsif @google_credentials.respond_to?(:client_email)
            @google_credentials.client_email
          end

          signing_key = if @google_credentials.respond_to?(:signing_key)
            @google_credentials.signing_key
          elsif @google_credentials.respond_to?(:private_key)
            @google_credentials.private_key
          end

          unless issuer && signing_key
            raise Firebase::Admin::ArgumentError, "Custom token generation requires service account credentials"
          end

          now_seconds = Time.now.to_i
          payload = {
            iss: issuer,
            sub: issuer,
            aud: GOOGLE_AUDIENCE,
            iat: now_seconds,
            exp: now_seconds + (60 * 60),
            uid: uid
          }

          unless claims.nil? || claims.empty?
            raise ArgumentError, "claims must be a Hash" unless claims.is_a?(Hash)
            payload[:claims] = claims
          end

          JWT.encode(payload, signing_key, "RS256")
        end
      end
    end
  end
end
