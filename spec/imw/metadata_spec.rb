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

  describe "setting URLs" do
    describe "without a base URL" do
      it "should set 'foobar' to 'foobar'" do
        @metadata['foobar'] = {'description' => 'bhaarg', 'fields' => ['a','b','c']}
        @metadata.keys.should include('foobar')
      end

      it "should set '/a/b/c/foobar' to '/a/b/c/foobar'" do
        @metadata['/a/b/c/foobar'] = {'description' => 'bhaarg', 'fields' => ['a','b','c']}
        @metadata.keys.should include('/a/b/c/foobar')
      end
      
    end

    describe "with a base URL" do
      before do
        FileUtils.mkdir_p('chimpo')
        @metadata.base = File.join(IMWTest::TMP_DIR, 'chimpo')
      end
      
      it "should set 'foobar' to '$base/foobar'" do
        @metadata['foobar'] = {'description' => 'bhaarg', 'fields' => ['a','b','c']}
        @metadata.keys.should include(File.join(IMWTest::TMP_DIR, 'chimpo', 'foobar'))
      end

      it "should set '/a/b/c/foobar' to '/a/b/c/foobar'" do
        @metadata['/a/b/c/foobar'] = {'description' => 'bhaarg', 'fields' => ['a','b','c']}
        @metadata.keys.should include('/a/b/c/foobar')
      end
      
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
      @metadata['foobar'] = {'description' => 'buzz', 'fields' => ['a','b', 'c']}
      @metadata.describe?('foobar').should be_true
      @metadata.describe?(IMW.open('foobar')).should be_true
    end

    it "should continue to be able to look up an absolute URI literally" do
      @metadata.describes?('http://www.google.com').should be_true
    end
    
  end
end
