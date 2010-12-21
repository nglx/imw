require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Formats::Csv do
  # we don't test Tsv as the differences from Csv are trivial and
  # effect only code within the FasterCSV library

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'formats/delimited/sample.csv'))
  end

  it "should be able to parse the CSV" do
    @sample.load[1].last.should == 'lemurinus'
  end

  it "should be able to write CSV" do
    data = [['foobar', 1, 2], ['bazbooz', 3, 4]]
    IMW.open!('test.csv') { |f| f << data }
    IMW.open('test.csv').load[1].last.should == "4"
  end

  describe "guessing a schema" do

    Dir[File.join(IMWTest::DATA_DIR, 'formats/delimited/with_schema/*')].each do |path|
      it "should correctly guess that with_schema/#{File.basename(path)} has headers in its first row" do
        IMW.open(path).fields_in_first_line?.should == true
      end
    end

    Dir[File.join(IMWTest::DATA_DIR, 'formats/delimited/without_schema/*')].each do |path|
      it "should correctly guess that without_schema/#{File.basename(path)} does not have headers in its first row" do
        IMW.open(path).fields_in_first_line?.should == false
      end
    end

    it "should automatically set the headers on a source with guessed headers" do
      resource = IMW.open(Dir[File.join(IMWTest::DATA_DIR, 'formats/delimited/with_schema/*')].first)
      resource.guess_fields!
      resource.delimited_options[:headers].class.should == Array
      resource.schema.should_not be_empty
    end

  end
  
end
