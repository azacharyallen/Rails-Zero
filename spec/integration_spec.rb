require 'webrick'
require 'rails_lite'
require 'debugger'

describe "the symphony of things" do
  let(:req) { WEBrick::HTTPRequest.new(:Logger => nil) }
  let(:res) { WEBrick::HTTPResponse.new(:HTTPVersion => '1.0') }
  let(:flash_cookie) { WEBrick::Cookie.new('_rails_lite_app_flash', { :notice => "I'm Flashing You!" }.to_json) }


  before(:all) do
    req.cookies << flash_cookie
    class Ctrlr < ControllerBase
      def route_render
        render_content("testing", "text/html")
      end

      def route_does_params
        render_content("got ##{ params["id"] }", "text/text")
      end

      def update_session
        session[:token] = "testing"
        render_content("hi", "text/html")
      end

      def update_flash
        flash[:errors] = ["I'm an error"]
        render_content("hi", "text/html")
      end
    end
  end

  describe "routes and params" do
    it "route instantiates controller and calls invoke action" do
      route = Route.new(Regexp.new("^/statuses/(?<id>\\d+)$"), :get, Ctrlr, :route_render)
      req.stub(:path) { "/statuses/1" }
      req.stub(:request_method) { :get }
      route.run(req, res)
      res.body.should == "testing"
    end

    it "route adds to params" do
      route = Route.new(Regexp.new("^/statuses/(?<id>\\d+)$"), :get, Ctrlr, :route_does_params)
      req.stub(:path) { "/statuses/1" }
      req.stub(:request_method) { :get }
      route.run(req, res)
      res.body.should == "got #1"
    end
  end

  describe "controller sessions" do
    let(:ctrlr) { Ctrlr.new(req, res) }

    it "exposes a session via the session method" do
      ctrlr.session.should be_instance_of(Session)
    end

    it "saves the session after rendering content" do
      ctrlr.update_session
      res.cookies.count.should == 1
      JSON.parse(res.cookies[0].value)["token"].should == "testing"
    end
  end

  describe "controller flashes" do
    let(:ctrlr) { Ctrlr.new(req, res) }

    it "exposes a flash via the flash method" do
      ctrlr.flash.should be_instance_of(Flash)
    end

    it "saves the flash after performing action" do
      ctrlr.update_flash
      flash = res.cookies.find { |cook| cook.name == '_rails_lite_app_flash'}
      JSON.parse(flash.value).has_key?("errors").should be(true)
    end

    it "Response should not contain old flash data" do
      ctrlr.update_flash
      flash = res.cookies.find { |cook| cook.name == '_rails_lite_app_flash'}
      JSON.parse(flash.value).has_key?("notice").should be(false)
    end
  end

end
