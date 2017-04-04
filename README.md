# mruby-smallhttp   
[![Build Status](https://travis-ci.org/nsheremet/mruby-smallhttp.svg?branch=master)](https://travis-ci.org/nsheremet/mruby-smallhttp)

mruby-smallhttp for mruby
## install by mrbgems

`mruby-smallhttp` it's small http lib for MRuby
## Install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|
  conf.gem :mgem => 'mruby-smallhttp'
end
```

## Example

### Requests
```ruby
# GET Request
HTTP.new("https://example.com/api/v1/users").get
#=> response

# POST Request
data = { name: 'value' }
headers = {'Content-Type' => 'application/json'}

HTTP.new("https://example.com/api/v1/users").post(data, headers)
#=> response

# PUT Request
http = HTTP.new("https://example.com/api/v1/users/1")
http.put(data, headers)

# DELETE Request
http = HTTP.new("https://example.com/api/v1/users/1")
http.delete(data, headers)
#=> response

# HEAD & OPTIONS Request
http = HTTP.new("https://example.com/api/v1/users/1")
http.request("HEAD", body, header)
#=> response
```

### How to send file
```ruby
# How to send file in post request
body = { name: 'value', file: File.read('filename') }
header = { 'Content-Type' => 'multipart/form-data' }
http = HTTP.new("https://example.com/api/v1/users/1")
http.post(body, header)
#=> response
```
`Content-Type` supported: `application/json`, `application/x-www-form-urlencoded`, `multipart/form-data`

## License
under the MIT License:
- see LICENSE file
