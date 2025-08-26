require_relative "../../../spec_helper"

describe Firebase::Admin::Auth::CustomTokenGenerator do
  let(:app) { Firebase::Admin::App.new(credentials: FakeCredentials.from_file(fixture("credentials.json"))) }
  let(:google_creds) { app.credentials.credentials }
  let(:public_key) { google_creds.signing_key.public_key }

  subject(:generator) { described_class.new(app) }

  describe "#create_custom_token" do
    it "generates a signed JWT with expected claims and RS256 signature" do
      uid = "user-123"
      claims = { premium_account: true, group: "alpha" }

      token = generator.create_custom_token(uid, claims)

      payload, header = JWT.decode(token, public_key, true, { algorithm: "RS256" })

      expect(payload["iss"]).to eq(google_creds.issuer)
      expect(payload["sub"]).to eq(google_creds.issuer)
      expect(payload["aud"]).to eq("https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit")
      expect(payload["uid"]).to eq(uid)
      expect(payload["claims"]).to include("premium_account" => true, "group" => "alpha")
      expect(payload["exp"]).to be > payload["iat"]
    end

    it "omits claims when none provided" do
      uid = "user-456"
      token = generator.create_custom_token(uid)
      payload, _header = JWT.decode(token, public_key, true, { algorithm: "RS256" })
      expect(payload.key?("claims")).to be(false)
    end

    it "raises when uid is empty" do
      expect { generator.create_custom_token("") }.to raise_error(Firebase::Admin::ArgumentError)
    end

    it "raises when claims is not a Hash" do
      expect { generator.create_custom_token("user", [1, 2, 3]) }.to raise_error(Firebase::Admin::ArgumentError)
    end
  end
end
