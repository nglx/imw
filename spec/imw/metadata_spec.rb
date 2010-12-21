require File.dirname(__FILE__) + "/../spec_helper"

describe IMW::Metadata do

  before do
    @metadata = IMW::Metadata.new({'foobar' => {'description' => 'buzz', 'fields' => ['a','b', 'c']}, 'http://www.google.com' => { 'description' => 'google', 'fields' => ['d', 'e', 'f'] }})
  end

  describe "matching URLs without a base" do

    it "should be able to look up a relative URI literally" do
      @metadata.describes?('foobar').should be_true
    end

    it "should be able to look up a relative URI when passed an IMW::Resource" do
      @metadata.describes?(IMW.open('foobar')).should be_true
    end

    it "should be able to look up an absolute URI literally" do
      @metadata.describes?('http://www.google.com').should be_true
    end

    it "should rightly fail to literally look up a URI it doesn't know about" do
      @metadata.describes?('bungler').should be_false
    end
    
  end

  describe "matching URLs with a base" do

    it "should raise an error when trying to use a base URI that doesn't exist" do
      lambda { @metadata.base = 'chimpo' }.should raise_error(IMW::PathError)
    end

    it "should raise an error when trying to use a base URI that isn't a directory" do
      IMW.open!('chimpo') { |f| f.write('a file') }
      lambda { @metadata.base = 'chimpo' }.should raise_error(IMW::PathError)
    end

    it "should be able to look up a URI relative to its base" do
      FileUtils.mkdir_p('chimpo')
      @metadata.base = File.join(IMWTest::TMP_DIR, 'chimpo')
      @uri = File.join(IMWTest::TMP_DIR, 'chimpo', 'foobar')
      @metadata.describe?(@uri).should be_true
      @metadata.describe?(IMW.open(@uri)).should be_true
    end

    it "should continue to be able to look up an absolute URI literally" do
      @metadata.describes?('http://www.google.com').should be_true
    end
    
  end
  
end
