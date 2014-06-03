require 'rails_lite'
require_relative '../lib/rails_lite/flash.rb'
require 'debugger'

describe Flash do
  let(:req) { WEBrick::HTTPRequest.new(:Logger => nil) }
  let(:res) { WEBrick::HTTPResponse.new(:HTTPVersion => '1.0') }
  let(:flash_cookie) { WEBrick::Cookie.new('_rails_lite_app_flash', { :notice => "I'm Flashing You!", :errors => ["Something", "Wrong"]}.to_json) }


  it "deserializes json flash cookie if one exists" do
    req.cookies << flash_cookie
    flash = Flash.new(req)
    flash['notice'].should == "I'm Flashing You!"
  end

  it "adds new content to response" do
    req.cookies << flash_cookie
    flash = Flash.new(req)
    flash[:new_flash] = "A New Flash"
    flash.store_flash(res)
    flash = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
    JSON.parse(flash.value).has_key?("new_flash").should be(true)
  end

  it "does not store contents of old cookie in response" do
    #debugger
    req.cookies << flash_cookie
    flash = Flash.new(req)
    flash[:new_flash] = "A New Flashe"
    flash.store_flash(res)
    flash = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
    JSON.parse(flash.value).has_key?("notice").should be(false)
  end

  it "content added with flash.now is not stored in the response" do
    flash = Flash.new(req)
    flash.now[:new_flash] = "A New Flash"
    flash.store_flash(res)
    flash.flash_now[:new_flash].should eq("A New Flash")
    res.cookies.count.should be(0)
  end

  describe "#store_flash" do
    context "without flash in request" do
      before(:each) do
        flash = Flash.new(req)
        flash['first_key'] = 'first_val'
        flash.store_flash(res)
      end

      it "adds new cookie with '_rails_lite_app_flash' name to response" do
        flash = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        flash.should_not be_nil
      end

      it "stores the cookie in json format" do
        flash = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        JSON.parse(flash.value).should be_instance_of(Hash)
      end
    end #without flash in request
  end #store flash
end #Flash