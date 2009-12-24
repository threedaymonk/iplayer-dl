require 'net/http'
require 'uri'

class Net::HTTPResponse # Monkey-patch in some 21st-century functionality
  include Enumerable

  def cookies
    inject([]){ |acc, (key, value)|
      key == 'set-cookie' ? acc << value.split(/;/).first : acc
    }
  end

  def to_hash
    @to_hash ||= inject({}){ |hash, (key, value)|
      hash[key] = value
      hash
    }
  end
end

module IPlayer
class Browser

  # Used by Safari Mobile
  IPHONE_UA  = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_1_2 like Mac OS X; en-us)'+
               'AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7D11 Safari/528.16'

  # Used by Quicktime
  QT_UA      = 'Apple iPhone v1.1.4 CoreMedia v1.0.0.4A102'

  # Safari, for no good reason
  DESKTOP_UA = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_4; en-gb) '+
               'AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.20.1'

  DEFAULT_HEADERS = {
    'Accept'          => '*/*',
    'Accept-Language' => 'en',
    'Connection'      => 'keep-alive',
    'Pragma'          => 'no-cache'
  }

  def initialize(http_class = Net::HTTP)
    @http_class = http_class
  end

  def post(location, data, headers={}, &blk)
    request(:post, location, data, headers, &blk)
  end

  def get(location, headers={}, &blk)
    request(:get, location, nil, headers, &blk)
  end

  def request(type, location, data, headers, &blk)
    url = URI.parse(location)
    http = @http_class.new(url.host, url.port)
    path = url.path
    if url.query
      path << '?' << url.query
    end
    headers_to_send = DEFAULT_HEADERS.merge(headers)
    if defined? DEBUG
      puts path
      headers_to_send.each do |k,v|
        puts " -> #{k}: #{v}"
      end
    end
    response =
      case type
      when :get
        http.request_get(path, headers_to_send, &blk)
      when :post
        http.request_post(path, data, headers_to_send, &blk)
      end
    if defined? DEBUG
      response.each do |k,v|
        puts "<-  #{k}: #{v}"
      end
    end
    response
  end

end
end
