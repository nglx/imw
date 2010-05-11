require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Resource do

  describe "handling missing methods" do
    before do
      @resource = IMW::Resource.new('/home/foof.txt', :skip_modules => true)
      @table    = @resource.instance_variable_get('@table')
    end

    it "should not set any table values on initialization" do
      @table[:is_remote].should be_nil
    end

    it "should return nil when accessing an unset table value" do
      @table[:is_remote].should be_nil
    end

    it "should return nil when querying an unset table value" do
      @resource.is_remote?.should be_nil
    end

    it "should be able to set a table value" do
      @resource.is_remote = true
      @table[:is_remote].should be_true
      @resource.is_remote = 17
      @table[:is_remote].should == 17
    end

    it "should be able to access a set table value" do
      @resource.is_remote = true
      @resource.is_remote.should be_true
      @resource.is_remote = 17
      @resource.is_remote.should == 17
    end

    it "should be able to query a set table value" do
      @resource.is_remote = true
      @resource.is_remote?.should be_true
      @resource.is_remote = 17
      @resource.is_remote?.should == 17
    end
  end

  describe "parsing various and sundry URIs should correctly parse a" do
    
    before do
      IMW::Resources.should_receive(:extend_resource!).with(an_instance_of(IMW::Resource))
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
    IMW::Resources.should_not_receive(:extend_resource!)
    IMW::Resource.new("/path/to/some/file.txt", :skip_modules => true)
  end
   
end




