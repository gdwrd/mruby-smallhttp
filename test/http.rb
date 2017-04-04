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
  http = HTTP.new("http://mruby.org/about/")
  response = http.request("GET")

  assert_equal response.empty?, false
end

assert_equal("make a request with method missing") do
  response = HTTP.new("http://mruby.org/about/").get

  assert_equal response.empty?, false
end
