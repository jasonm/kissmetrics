require 'net/http'
require 'net/https'
require 'cgi'

class Kissmetrics
  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def identify(identity)
    @identity = identity
  end

  def record(event, properties={})
    request('/e', properties.merge({
      '_n' => event
    }))
  end

  def alias(old_identity, new_identity)
    request('/a', {
      '_p' => old_identity,
      '_n' => new_identity
    })
  end

  def set(properties)
    request('/s', properties)
  end

  private

  def host
    'trk.kissmetrics.com'
  end

  def port
    443
  end

  def request(path, params)
    http = Net::HTTP.new(host, port)
    http.use_ssl = true
    http.get("#{path}?#{query_string(params)}")
  end

  def query_string(params)
    query = params.clone
    query['_k'] = @api_key
    query['_p'] = @identity if @identity

    QueryStringHash.new(query)
  end

  class QueryStringHash
    def initialize(hash)
      @hash = hash
    end

    def to_s
      @hash.collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join('&')
    end
  end
end
