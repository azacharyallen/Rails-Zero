require 'uri'
require 'addressable/uri'

class Params
  # Merge params from query string, body, route
  attr_reader :params
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)

  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys ||= []
    @permitted_keys += keys
  end

  def require(key)
    raise AttributeNotFoundError unless @params.keys.include?(key)
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # Parses query string into nested hash
  def parse_www_encoded_form(www_encoded_form)
    query_string = www_encoded_form
    #
    return if query_string.nil?
    query_string.split("&").each do |key_value_string|
      parse_key(key_value_string)
    end
  end

  # Returns nested hash of a key
  def parse_key(key_value_string)
    key, value = key_value_string.split("=")
    top_key = key.scan(/^\w+/).first
    nested_keys = key.scan(/\[(\w+)\]/).flatten
    nested_keys.unshift top_key

    base = @params
    until nested_keys.length == 1 do
      key = nested_keys.shift 
      base[key] = base[key] || {}
      base = base[key]
    end
    base[nested_keys.first] = value
  end
end
