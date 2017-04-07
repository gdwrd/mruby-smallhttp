class HTTP
  attr_accessor :url

  # TODO need better regexp
  URL_REGEXP = /^((http[s]?):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/
  HOST_REGEXP = /^(?:https?:\/\/)?(?:[^@\/\n]+@)?(?:www\.)?([^:\/\n]+)/

  HTTP_VERSION = 'HTTP/1.1'
  CL_METHODS = %w(POST PUT)
  C_TYPE = %w(application/json application/x-www-form-urlencoded multipart/form-data)
  SEP = "\r\n"

  DEFAULTS = {
    port: 80,
    ssl_port: 443,
    accept: '*/*',
  }

  ##
  # Initialize HTTP
  #
  # Params:
  # - url {String} target url
  # - port {Int} traget port
  #
  # Response: Response.new
  #
  def initialize(url, port = nil)
    @url = {}
    parse_url(url, port)
  end

  ##
  # GET Request
  #
  # Params:
  # - body    {Hash} Request Body
  # - header  {Hash} Reqeust Header
  #
  # Response: Response.new
  #
  def get(body = {}, header = {})
    request("GET", body, header)
  end

  ##
  # POST Request
  #
  # Params:
  # - body    {Hash} Request Body
  # - header  {Hash} Reqeust Header
  #
  # Response: Response.new
  #
  def post(body = {}, header = {})
    request("POST", body, header)
  end

  ##
  # PUT Request
  #
  # Params:
  # - body    {Hash} Request Body
  # - header  {Hash} Reqeust Header
  #
  # Response: Response.new
  #
  def put(body = {}, header = {})
    request("PUT", body, header)
  end

  ##
  # DELETE Request
  #
  # Params:
  # - body    {Hash} Request Body
  # - header  {Hash} Reqeust Header
  #
  # Response: Response.new
  #
  def delete(body = {}, header = {})
    request("DELETE", body, header)
  end

  ##
  # Send Request
  #
  # Params:
  # - method  {String}  Request Method
  # - body    {Hash}    Request Body
  # - header  {Hash}    Request Header
  #
  # Response: Response.new
  #
  def request(method, body = {}, header = {})
    request  = create_request(method.upcase, body, header)
    response_data = send_request(request)
    Response.new(response_data)
  end

private

  ##
  # Send Request method
  #
  # Params:
  # - data {String} body request
  #
  # Response: String response
  #
  def send_request(data, result = {})
    socket = TCPSocket.new(@url[:host], @url[:port])

    if @url[:ssl_enabled]
      e = PolarSSL::Entropy.new
      c = PolarSSL::CtrDrbg.new(e)
      ssl = PolarSSL::SSL.new
      ssl.set_endpoint PolarSSL::SSL::SSL_IS_CLIENT
      ssl.set_rng(c)
      ssl.set_socket(socket)
      ssl.handshake
      ssl.write(data)

      result = ssl.read(2048)
      ssl.close_notify
      socket.close
      ssl.close
    else
      socket.write(data)

      result = socket.read(1024)
      socket.close
    end

    result
  end

  ##
  # Create body request method
  #
  # Params:
  # - method {String} request method
  # - body {Hash} request body
  # - header {Hash} request header
  #
  # Response: Request as String
  #
  def create_request(method, body, header, str = "")
    @data = organize_header(header)
    body = create_body(@data['Content-Type'], body)

    if CL_METHODS.include?(method)
      @data['Content-Length'] = body.length
    end

    str += sprintf("%s %s %s", method, @url[:path], HTTP_VERSION) + SEP

    @data.keys.sort.each do |k|
      str += sprintf("%s: %s", k, @data[k]) + SEP
    end

    str + SEP + body
  end

  ##
  # Create Body for Content-Type
  #
  # Params:
  # - type {String} Content-Type
  # - body {Hash} Request body
  #
  # Response: Request Body as String
  #
  def create_body(type, body)
    if type == C_TYPE[1]                               # if Content-Type => 'application/x-www-form-urlencoded'
      str = ""
      body.each do |k, v|
        str += k.to_s + '=' + v.to_s
        str += '&' unless body.keys.last == k
      end
      return str
    elsif type == C_TYPE[2]                            # if Content-Type => 'multipart/form-data'
      @boundary = (0...32).map { ('a'..'z').to_a[rand(26)] }.join
      @data['Content-Type'] = [@data['Content-Type'], 'boundary=' + @boundary].join('; ')

      str = ""
      body.each do |k, v|
        str += "--#{@boundary}" + SEP
        if v.kind_of?(File)
          file = File.open(v.path, 'rb')
          filename = File.basename(v.path)
          str += "Content-Disposition: form-data; name=\"#{k.to_s}\"; filename=\"#{filename}\"" + SEP * 2
          str += file.read + SEP
        else
          str += "Content-Disposition: form-data; name=\"#{k.to_s}\"" + SEP * 2
          str += v.to_s + SEP
        end
      end

      str += "--#{@boundary}--"

      return str
    else                                              # if Content-Type => 'application/json'
      return body.to_json
    end
  end

  ##
  # Create Header for request
  #
  # Params:
  # - header {Hash} Request Header
  #
  # Response: Header as Hash
  #
  def organize_header(header, data = {})
    header.each do |key, value|
      if !data[key].nil?
        if data[key].kind_of?(Array)
          data[key] << value
        else
          data[key] = [data[key], value]
        end
      else
        data[key] = value
      end
    end

    data['Host'] ||= @url[:host]
    data['Accept'] ||= DEFAULTS[:accept]
    data['Connection'] ||= 'close'
    data['Content-Type'] = C_TYPE[0] unless C_TYPE.include?(data['Content-Type'])

    data
  end

  ##
  # Parse URL
  #
  # Params:
  # - url {String}
  # - port {Int}
  #
  # Response: parse URL to @url
  #
  def parse_url(url, port)
    if !!url[URL_REGEXP]
      @url[:port] = port.nil? ? !!url[/^(https)/] ? DEFAULTS[:ssl_port] : DEFAULTS[:port] : port
      @url[:ssl_enabled] = !!url[/^(https)/]

      @url[:host] = url[HOST_REGEXP].split(url[/^(http[s]?)/] + '://')[1]
      @url[:path] = url.split(url[HOST_REGEXP])[1]
    else
      raise ArgumentError
    end
  end
end
