require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  attr_reader :session_cookie
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        @session_cookie = JSON.parse(cookie.value)
      end
    end
    @session_cookie ||= {}
  end #initialize

  def [](key)
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app", @session_cookie.to_json)
  end
end
