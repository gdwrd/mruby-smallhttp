class Response
  attr_accessor :status, :headers, :body, :response

  ##
  # Initialize Response
  #
  # Params:
  # - data {String} Response string
  #
  # Response: Response.new
  #
  def initialize(data)
    @headers = {}
    @status = nil
    @response = data

    if data.include?(HTTP::SEP * 2)
      h_data, @body = data.split(HTTP::SEP + HTTP::SEP, 2)
    else
      h_data = data
    end

    header = h_data.split(HTTP::SEP)

    if header[0].include?("HTTP/1")
      @status = header[0].split(" ", 3)[1].to_i
    end

    header.each do |l|
      if l.include?(": ")
        k, v = l.split(": ")
        if !@headers[k].nil?
          if @headers[k].kind_of?(Array)
            @headers[k] << v
          else
            @headers[k] = [@headers[k], v]
          end
        else
          @headers[k] = v
        end
      end
    end
  end
end
