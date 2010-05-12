require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Formats::Json do

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'sample.json'))
  end

  it "should be able to parse the JSON" do
    @sample.load['monkeys'].first['monkey']['id'].should == 1
  end

  it "should be able to write JSON" do
    IMW.open!('test.json').dump({ 'foobar' => 3, 'bazbooz' => 4 })
    IMW.open('test.json').load['foobar'].should == 3
  end
  
  it "should yield each key and value when the JSON is a hash and it's given a block" do
    @sample.load do |key, value|
      value.size.should == 130
    end
  end

  it "should yield each element when the JSON is an array and it's given a block" do
    IMW.open!('test.json').dump([1,2,3])
    num = 1
    IMW.open('test.json').load do |parsed_num|
      parsed_num.should == num
      num +=1
    end
  end
end
