require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Schemes::HTTP do

  describe "finding its effective basename" do
    it "should use the real basename when present" do
      IMW.open('http://www.google.com/foobar').effective_basename.should == 'foobar'
    end

    it "should use '_index' when at the root (without a slash)" do
      IMW.open('http://www.google.com').effective_basename.should == '_index'
    end

    it "should use '_index' when at the root (even when a slash is given)" do
      IMW.open('http://www.google.com/').effective_basename.should == '_index'
    end
    
  end
end
