require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Schemes::S3 do

  describe 'manipulating S3 paths' do
    before do
      @resource = IMW::Resource.new('s3://mybucket/foobar/foo.txt')
    end

    it "should set the bucket" do
      @resource.bucket.should == 'mybucket'
    end

    it "can generate an S3N url" do
      @resource.s3n_url.should == 's3n://mybucket/foobar/foo.txt'
    end

    it "can join path segments" do
      @resource.join('a', 'b/c').to_s.should == File.join(@resource.to_s, 'a/b/c')
    end
  end
  
end
