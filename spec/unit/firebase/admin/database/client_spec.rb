require "./spec/unit/helpers/database_helper"
require_relative "../../../spec_helper"

describe Firebase::Admin::Database::Client do
  include DatabaseHelper

  before do
    config = Firebase::Admin::Config.from_file(fixture("config.json"))
    creds = FakeCredentials.from_file(fixture("credentials.json"))
    @app = Firebase::Admin::App.new(credentials: creds, config: config)
  end

  describe "#get" do
    it "returns a Response with parsed JSON body" do
      stub_db_request(:get, "test/path.json", file: "database/get.json")
      res = @app.database.get("test/path")
      expect(res).to be_a(Firebase::Admin::Database::Response)
      expect(res.success?).to eq(true)
      expect(res.code).to eq(200)
      expect(res.body).to eq({"hello" => "world"})
    end

    it "json-encodes orderBy and limit query options in the URL" do
      stub_db_request(:get, "todos.json?orderBy=%22created%22&limitToFirst=1", file: "database/get.json")
      res = @app.database.get("todos", query: {orderBy: "created", limitToFirst: 1})
      expect(res.body).to eq({"hello" => "world"})
    end
  end

  describe "#set" do
    it "writes JSON to the path" do
      stub_db_request(:put, "test/path.json", status: 200, headers: {"etag" => "\"abc\""})
      res = @app.database.set("test/path", {"a" => 1})
      expect(res.success?).to eq(true)
      expect(res.etag).to eq("\"abc\"")
    end

    it "supports query options (e.g. print=silent) on writes" do
      stub_db_request(:put, "test/path.json?print=silent", status: 200)
      res = @app.database.set("test/path", {"a" => 1}, query: {print: "silent"})
      expect(res.success?).to eq(true)
    end
  end

  describe "#push" do
    it "returns the generated name" do
      stub_db_request(:post, "todos.json", file: "database/push.json")
      res = @app.database.push("todos", {"name" => "Pick the milk"})
      expect(res.body).to eq({"name" => "-INOQPH-aV_psbk3ZXEX"})
    end
  end

  describe "#update" do
    it "patches the path" do
      stub_db_request(:patch, "test/path.json", status: 200)
      res = @app.database.update("test/path", {"a" => 2})
      expect(res.success?).to eq(true)
    end

    it "rejects non-hash update payloads" do
      expect { @app.database.update("test/path", ["a"]) }.to raise_error(Firebase::Admin::ArgumentError)
    end
  end

  describe "#delete" do
    it "deletes the path" do
      stub_db_request(:delete, "test/path.json", status: 200)
      res = @app.database.delete("test/path")
      expect(res.success?).to eq(true)
    end
  end

  describe Firebase::Admin::Database::ServerValue do
    it "exposes TIMESTAMP sentinel" do
      expect(Firebase::Admin::Database::ServerValue::TIMESTAMP).to eq({".sv" => "timestamp"})
    end
  end
end


