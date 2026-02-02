module DatabaseHelper
  def database_base_url
    "https://test-adminsdk-project-config.firebaseio.com"
  end

  def stub_db_request(method, path_with_json, file: nil, status: 200, headers: {})
    uri = "#{database_base_url}/#{path_with_json}"
    response_headers = {content_type: "application/json; charset=utf-8"}.merge(headers)

    body =
      if file
        fixture(file)
      else
        ""
      end

    stub_request(method, uri).to_return(
      status: status,
      body: body,
      headers: response_headers
    )
  end
end


