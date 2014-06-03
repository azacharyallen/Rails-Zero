require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative 'flash'
require 'debugger'
module URLHelper
  
end #URLHelper

class ControllerBase
  attr_reader :params#, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @request, @response = req, res
    @params = Params.new(@request, route_params)
    @already_built_response = false
  end #initialize

  def req
    @request
  end

  def res
    @response
  end
  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise Exception.new("Already Rendered Response") if already_built_response?
    @response.body = content
    @response['Content-Type'] = type
    @session.store_session(@response) if @session
    @flash.store_flash(@response) if @flash
    @already_built_response = true
  end #render_content

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise Exception.new("Already Rendered Response") if already_built_response?
    @response.status = 302
    @response["Location"] = url
    @session.store_session(@response) if @session
    @flash.store_flash(@response) if @flash
    @already_built_response = true
  end #redirect_to

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = ERB.new(File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb"))
    bindings = binding()
    render_content(template.result(bindings), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@request)
    @session
  end

  def flash
    @flash ||= Flash.new(@request)
    @flash
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name.to_s) unless already_built_response?
  end
end
