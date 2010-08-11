require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::Schemata do

  describe "initalizing" do

    it "should accept a hash" do
      IMW::Metadata::Schemata.new('a' => ['a', 'b']).should == { 'a' => [{:name => 'a'}, {:name => 'b'}] }
    end
  end

  describe 'loading' do

    it "should accept a Hash in a resource" do
      data = {'a' => ['a', 'b']}
      resource = IMW.open('some_resource')
      IMW.should_receive(:open).with(resource).and_return(resource)
      resource.should_receive(:load).and_return(data)
      IMW::Metadata::Schemata.load(resource).should == { 'a' => [{:name => 'a'}, {:name => 'b'}] }
    end
  end

  describe "constructing absolute URIs" do

    before { @schemata = IMW::Metadata::Schemata.new }
    
    it "should return the resource given without a base" do
      @schemata.send(:absolute_uri, 'path/to/something').should == 'path/to/something'
    end

    it "should return the absolute URI with a base" do
      path = File.join(IMWTest::TMP_DIR, 'schemata.yaml')
      FileUtils.mkdir_p(path)
      @schemata.base = path
      @schemata.send(:absolute_uri, 'path/to/something').should == File.join(IMWTest::TMP_DIR, '/path/to/something')
    end
  end
  
end
