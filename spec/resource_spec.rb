require 'rubygems'
require 'rspec'
require 'imw' ; include IMW

describe "IMW::Resource" do

  context "The Resource class" do

    it "should respond to the method open" do
      IMW::Resource.should respond_to(:open)
    end

    context "Resource.open" do
      before :each do
        @uri = "test.csv"
      end

      it "should return an IMW::Resource object" do
        Resource.open(@uri).should be_instance_of(IMW::Resource)
      end

      it "should return the value of the block if given a block" do
        Resource.open(@uri) { |obj| nil }.should be_nil
      end

      it "should accept a block and yield an IMW::Resource object" do
        Resource.open(@uri) do |obj|
          obj.should be_instance_of(IMW::Resource)
        end
      end

    end

    it "should respond to the method exists?" do
      Resource.should respond_to(:exists?)
    end

    context "Resource.exists?" do
      before :each do
        @file = "test"
      end

      it "should return either true or false" do
        Resource.exists?(@file).should == !!Resource.exists?(@should)
      end

    end
  end

  it "should read a Resource and return a string" do
    Resource
  end

  context "A Resource instance" do
    before :each do
      @uri = "test.csv"
      @resource = Resource.new(@uri)
    end

    it "should accept a Resource access mode when instantiated" do
      lambda { Resource.new(@uri, 'w') }.should_not raise_error(Exception)
    end

    it "should raise an error if given an invalid Resource mode" do
      lambda { Resource.new(@uri, 'f') }.should raise_error(IMW::Error::FileModeError)
    end

    it "should return the uri as a IMW::Uri object" do
      @resource.uri.should be_instance_of(IMW::Uri)
    end

    it "should respond to the method close" do
      @resource.should respond_to(:close)
    end

  end

end
