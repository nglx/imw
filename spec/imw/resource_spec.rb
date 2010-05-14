require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Resource do

  describe "handling missing methods" do
    before do
      @resource = IMW::Resource.new('/home/foof.txt', :skip_modules => true)
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

  describe "parsing various and sundry URIs should correctly parse a" do
    
    before do
      IMW::Resource.should_receive(:extend_resource!).with(an_instance_of(IMW::Resource))
    end

    it "local file path" do
      resource = IMW::Resource.new("/home/foo.txt")
      resource.stub!(:path).and_return("/home/foo.txt")

      resource.scheme.should    be_nil
      resource.dirname.should   == '/home'
      resource.basename.should  == 'foo.txt'
      resource.extname.should   == '.txt'
      resource.extension.should == 'txt'
      resource.name.should      == 'foo'
    end

    it "local file path with spaces in the name" do
      resource = IMW::Resource.new("/home/foo bar.txt")
      resource.stub!(:path).and_return("/home/foo bar.txt")
      resource.name.should == 'foo bar'
    end

    it "local file path with an explicit file:// scheme" do
      resource = IMW::Resource.new("file:///home/foo.txt")
      resource.scheme.should == 'file'
    end

    it "web URL with query and fragment" do
      resource = IMW::Resource.new("http://mysite.com/some/page?param=value#frag")
      resource.stub!(:path).and_return("/some/page")
      resource.scheme.should        == 'http'
      resource.dirname.should       == '/some'
      resource.basename.should      == 'page'
      resource.extname.should       == ''
      resource.extension.should     == ''
      resource.name.should          == 'page'
    end

  end

  it "should open a URI without attempting to extend with modules if so asked" do
    IMW::Resource.should_not_receive(:extend_resource!)
    IMW::Resource.new("/path/to/some/file.txt", :skip_modules => true)
  end
   
end




