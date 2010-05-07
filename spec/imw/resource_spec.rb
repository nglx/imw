require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Resource do

  describe "parsing various and sundry URIs should correctly parse a" do
    
    before do
      IMW::Resources.should_receive(:extend_resource!).with(an_instance_of(IMW::Resource))
    end

    it "local file path" do
      resource = IMW::Resource.new("/home/foo.txt")

      resource.scheme.should    be_nil
      resource.host.should      be_nil
      resource.path.should      == '/home/foo.txt'
      resource.dirname.should   == '/home'
      resource.basename.should  == 'foo.txt'
      resource.extname.should   == '.txt'
      resource.extension.should == 'txt'
      resource.name.should      == 'foo'
      resource.local?.should    be_true
      resource.remote?.should   be_false
    end

    it "local file path with spaces in the name" do
      resource = IMW::Resource.new("/home/foo bar.txt")
      resource.name.should == 'foo bar'
    end

    it "local file path with an explicit file:// scheme" do
      resource = IMW::Resource.new("file:///home/foo.txt")
      resource.scheme.should == 'file'
      resource.local?.should be_true
    end

    it "web URL with query and fragment" do
      resource = IMW::Resource.new("http://mysite.com/some/page?param=value#frag")

      resource.scheme.should        == 'http'
      resource.host.should          == "mysite.com"
      resource.path.should          == "/some/page"
      resource.dirname.should       == '/some'
      resource.basename.should      == 'page'
      resource.extname.should       == ''
      resource.extension.should     == ''
      resource.name.should          == 'page'
      resource.query_string.should  == "param=value"
      resource.fragment.should      == "frag"
      
      resource.local?.should        be_false
      resource.remote?.should       be_true
    end

    it "should automatically expand paths" do
      resource = IMW::Resource.new("wakka_wakka")
      resource.dirname.should == IMWTest::TMP_DIR
      resource.path.should == File.join(IMWTest::TMP_DIR, 'wakka_wakka')
    end
  end

  it "should open a URI without attempting to extend with modules if so asked" do
    IMW::Resources.should_not_receive(:extend_resource!)
    IMW::Resource.new("/path/to/some/file.txt", :skip_modules => true)
  end
   
end




