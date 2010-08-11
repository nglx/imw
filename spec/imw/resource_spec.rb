require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Resource do

  describe "handling missing methods" do
    before do
      @resource = IMW::Resource.new('/home/foof.txt', :no_modules => true)
    end

    it "should return false when querying with a method that isn't defined" do
      @resource.is_remote?.should be_false
    end

    it "should raise an IMW::NoMethodError in any other case" do
      lambda { @resource.do_seomthing }.should raise_error(IMW::NoMethodError)
    end

    it "should print the modules it's been extended by when raising an IMW::NoMethodError" do
      begin
        @resource.extend(IMW::Schemes::Local::Base)
        @resource.do_something
      rescue IMW::NoMethodError => e
        e.message.should match(/extended by IMW::Schemes::Local::Base/)
      end
    end
  end

end




