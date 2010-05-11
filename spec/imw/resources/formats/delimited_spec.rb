require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Formats::Csv do
  # we don't test Tsv as the differences from Csv are trivial and
  # effect only code within the FasterCSV library

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'sample.csv'))
  end

  it "should be able to parse the CSV" do
    @sample.load[1].last.should == 'lemurinus'
  end

  it "should be able to write CSV" do
    data = [['foobar', 1, 2], ['bazbooz', 3, 4]]
    IMW.open!('test.csv').dump(data)
    IMW.open('test.csv').load[1].last == 4
  end

  it "should yield each row when load is given a block" do
    @sample.load do |row|
      row.class.should == Array
      break
    end
  end

  it "can map each row with a block" do
    @sample.map do |row|
      row.first
    end.class.should == Array
  end
end
