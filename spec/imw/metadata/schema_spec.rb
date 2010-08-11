require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::Schema do

  describe "initializing" do
    it "should accept an array" do
      IMW::Metadata::Schema.new([1,2,3]).should == [{:name => '1'}, {:name => '2'}, {:name => '3'}]
    end

    it "should dup a Schema if given one" do
      orig_schema = IMW::Metadata::Schema.new([1,2,3])
      IMW::Metadata::Schema.new(orig_schema).should == orig_schema
    end
  end

  describe 'loading' do
    it "should load an Array in a resource" do
      resource = IMW.open('some_resource')
      resource.should_receive(:load).and_return(%w[foo bar baz])
      IMW.should_receive(:open).and_return(resource)
      IMW::Metadata::Schema.load(resource.to_s).map { |field| field[:name] }.should == %w[foo bar baz]
    end

  end
  
end

