require File.dirname(__FILE__) + "/../../spec_helper"

class Klass
  include IMW::Utils::HasURI
end

def new_obj uri
  obj = Klass.new
  obj.uri = uri
  obj
end

describe IMW::Utils::HasURI do
  
  it "local file path" do
    obj = new_obj("/home/foo.txt")
    obj.stub!(:path).and_return("/home/foo.txt")

    obj.scheme.should    be_nil
    obj.dirname.should   == '/home'
    obj.basename.should  == 'foo.txt'
    obj.extname.should   == '.txt'
    obj.extension.should == 'txt'
    obj.name.should      == 'foo'
  end

  it "local file path with spaces in the name" do
    obj = new_obj("/home/foo bar.txt")
    obj.stub!(:path).and_return("/home/foo bar.txt")
    obj.name.should == 'foo bar'
  end

  it "local file path with an explicit file:// scheme" do
    obj = new_obj("file:///home/foo.txt")
    obj.scheme.should == 'file'
  end

  it "web URL with query and fragment" do
    obj = new_obj("http://mysite.com/some/page?param=value#frag")
    obj.stub!(:path).and_return("/some/page")
    obj.scheme.should        == 'http'
    obj.dirname.should       == '/some'
    obj.basename.should      == 'page'
    obj.extname.should       == ''
    obj.extension.should     == ''
    obj.name.should          == 'page'
  end

  it "should be able to strip URIs" do
    new_obj('/path/to/something').stripped_uri.to_s.should == '/path/to/something'
    new_obj('http://user:pass@example.com:8080/path/to/some/script.php?param=value#frag').stripped_uri.to_s.should == 'http://user:pass@example.com:8080/path/to/some/script.php'
  end

  it "should be able to return raw paths" do
    new_obj('s3://bucket/crazy url with # some dumb naming convention').raw_path.should == '/crazy url with # some dumb naming convention'
    new_obj('s3://bucket/crazy url with ?some dumb naming convention').raw_path.should  == '/crazy url with ?some dumb naming convention'
    new_obj('s3://bucket/crazy url with ?some dumb naming #convention').raw_path.should == '/crazy url with ?some dumb naming #convention'
    new_obj('s3://bucket/crazy url with #some dumb naming ?convention').raw_path.should == '/crazy url with #some dumb naming ?convention'
  end

end
