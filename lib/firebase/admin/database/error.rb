module Firebase
  module Admin
    module Database
      # A base class for errors raised by the Realtime Database client.
      class Error < Firebase::Admin::Error; end

      # Raised when a required database configuration option is missing.
      class ConfigurationError < Error; end
    end
  end
end


