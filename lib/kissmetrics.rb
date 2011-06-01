require 'net/http'
require 'net/https'
require 'cgi'

class Kissmetrics
  def initialize(api_key)
    @api_key = api_key
  end

  attr_reader :api_key

  def identify(identity)
    @identity = identity
  end

  def record(event, params={})
    request('/e', params.merge({
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

    hash_to_query_string(query)
  end

  def hash_to_query_string(hash)
    hash.collect { |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
  end
end
