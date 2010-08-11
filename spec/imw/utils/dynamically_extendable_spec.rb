require File.dirname(__FILE__) + "/../../spec_helper"

describe "extending resources with specific modules" do
  before do
    @class  = Class.new
    @class.send(:include, IMW::Utils::DynamicallyExtendable)
    @instance = @class.new
  end

  it "should raise an error when registering a malformed handler" do
    lambda { @class.register_handler("Foo", 3) }.should raise_error(IMW::ArgumentError)
  end

  it "should store in instances modules they've been extended by" do
    @foo = Module.new
    @instance.extend(@foo)
    @instance.modules.should include(@foo)
  end

  describe "evaluating handlers" do
    before do
      @proccer  = Module.new
      @class.send(:attr_accessor, :prop)
      @class.register_handler(@proccer, Proc.new { |instance| instance.prop })

      @regexper = Module.new
      @class.send(:define_method, :to_s) { 'whoa' }
      @class.register_handler(@regexper, /whoa/)
    end

    it "should extend an instance with a matching proc handler" do
      @instance.prop = true
      @instance.extend_appropriately!
      @instance.modules.should include(@proccer)
    end

    it "should not extend an instance with a non-matching proc handler" do
      @instance.prop = false
      @instance.extend_appropriately!
      @instance.modules.should_not include(@proccer)
    end

    it "should extend an instance with a matching regexp handler" do
      @instance.extend_appropriately!
      @instance.modules.should include(@regexper)
    end

    it "should not extend an instance with a non-matching regexp handler" do
      @class.send(:define_method, :to_s) { 'fowl' }
      @instance.extend_appropriately!
      @instance.modules.should_not include(@regexper)
    end

    it "should not extend an instance with a module it was asked to skip" do
      @instance.extend_appropriately!(:skip_modules => [@regexper])
      @instance.modules.should_not include(@regexper)
    end

    it "should not extend with any modules if asked" do
      @instance.extend_appropriately!(:no_modules => true)
      @instance.modules.should_not include(@regexper)
    end

    it "should use a module if asked to do so even if it's handler didn't match" do
      @instance.extend_appropriately!(:use_modules => [@proccer])
      @instance.modules.should include(@proccer)
    end
  end
end
