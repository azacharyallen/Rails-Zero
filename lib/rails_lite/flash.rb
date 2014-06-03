require 'json'
require 'webrick'

class Flash
  attr_reader :flash_cookie
  attr_reader :flash_now
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app_flash"
        @flash_now = JSON.parse(cookie.value)
        cookie = {}
      end
    end
    @flash_now ||= {}
    @flash_cookie = {}
  end #initialize

  def [](key)
    flash_now[key] || flash_cookie[key]
  end

  def []=(key, val)
    #@flash_cookie ||= {}
    @flash_cookie[key] = val
  end

  def now
    flash_now
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app_flash", @flash_cookie.to_json) unless @flash_cookie.empty?
  end
end #Flash