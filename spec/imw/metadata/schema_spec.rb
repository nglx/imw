require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::Schema do

  describe "initializing" do
    it "should merge with a Hash" do
      IMW::Metadata::Schema.new({:foo => 'foobar'}).should == { :foo => 'foobar' }
    end

    it "should merge with a Schema" do
      IMW::Metadata::Schema.new(IMW::Metadata::Schema.new({:foo => 'foobar'})).should == { :foo => 'foobar' }
    end

    it "should ignore anything else" do
      IMW::Metadata::Schema.new('foobar').should == {}
    end

    it "should accept empty args" do
      IMW::Metadata::Schema.new.should == {}
    end
    
  end
  
end
