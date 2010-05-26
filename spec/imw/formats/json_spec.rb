require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Formats::Json do

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'sample.json'))
  end

  it "should be able to parse the JSON" do
    @sample.load.first['id'].should == 1
  end

  it "should be able to write JSON" do
    IMW.open!('test.json').dump({ 'foobar' => 3, 'bazbooz' => 4 })
    IMW.open('test.json').load['foobar'].should == 3
  end
  
end
