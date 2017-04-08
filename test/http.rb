def run_with_catching_error(&b)
  e = nil
  begin
    b.call
  rescue => _e
    e = _e
  end

  return e
end

assert("initialize would not accept wrong link") do
  e = run_with_catching_error { HTTP.new("not_link") }

  assert_equal e.class, ArgumentError
end

assert("make a request") do
  http = HTTP.new("http://mruby.org")
  response = http.request("GET")

  assert_equal response.nil?, false
end

assert_equal("response should be parsed") do
  response = HTTP.new("http://www.mocky.io/v2/58e8c0ff120000731859b69d").get

  assert_equal response.status, 200
end

assert_equal("request headers should have key") do
  response = HTTP.new("http://www.mocky.io/v2/58e8c1501200006e1859b69f").post

  assert_equal response.headers.keys.include?("Key"), true
  assert_equal response.headers.values.include?("Value"), true
end

assert_equal("request body should parsed as JSON") do
  response = HTTP.new("http://www.mocky.io/v2/58e8c2071200008a1859b6a0").put

  assert_equal JSON::parse(response.body)["data"], "data"
  assert_equal JSON::parse(response.body)["status"], 200
end
