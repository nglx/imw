require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::Field do

  describe "initializing" do
    it "should parse a string into a hash" do
      IMW::Metadata::Field.new('foobar').should == { "name" => 'foobar' }
    end

    it "should raise an error on a Hash without a :name key" do
      lambda { IMW::Metadata::Field.new('foo' => 'bar') }.should raise_error(IMW::ArgumentError)
    end

    it "should accept a Hash with a :name key" do
      data = { 'name' => :foobar, 'title' => "Bazbooz", 'unit' => "m" }
      IMW::Metadata::Field.new(data).should == data
    end

    it "should dup a field if given one" do
      orig_field = IMW::Metadata::Field.new('foobar')
      IMW::Metadata::Field.new(orig_field).should == orig_field
    end
  end
  
end
