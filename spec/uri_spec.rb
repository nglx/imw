require 'rubygems'
require 'rspec'
require 'imw' ; include IMW

describe "IMW::Uri" do
  before :each do
    @uri = Uri.new("test.csv")
  end

  it "should respond to scheme" do
    @uri.should respond_to(:scheme)
  end

  context "A Uri.scheme" do
    before :each do
      @local = "/path/to/file.csv"
      @s3    = "s3://s3-bucket/path/to/file.csv"
      @hdfs  = "hdfs://namenodehost/path/to/file.csv"
    end

    it "should understand the local file scheme" do
      Uri.new(@local).scheme.should == 'Local'
    end

    it "should understand the s3 file scheme" do
      Uri.new(@s3).scheme.should == 'S3'
    end

    it "should understand the hadoop file system" do
      Uri.new(@hdfs).scheme.should == 'Hdfs'
    end

  end

  it "should respond to format" do
    @uri.should respond_to(:format)
  end

  context "A Uri.format" do
    before :each do
      @csv     = "foo.csv"
      @tsv     = "foo.tsv"
      @json    = "foo.json"
      @yaml    = "foo.yml"
      @invalid = "foor.bar"
    end

    it "should raise an error when given an invalid format" do
      lambda { Uri.new(@invalid) }.should raise_error(IMW::Error::InvalidFormatError)
    end

  end

end

