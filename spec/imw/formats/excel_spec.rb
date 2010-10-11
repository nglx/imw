require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Formats::Excel do
  
  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'formats/excel/sample.xls'))
  end

  it "should be able to parse the Excel document" do
    @sample.load[1].last.should == 'lemurinus'
  end

  it "should be able to create a snippet" do
    @sample.snippet[1].last.should == 'lemurinus'
  end

  # it "should be able to write CSV" do
  #   data = [['foobar', 1, 2], ['bazbooz', 3, 4]]
  #   IMW.open!('test.csv').emit(data)
  #   IMW.open('test.csv').load[1].last.should == "4"
  # end

  # it "should raise an error on an invalid schema" do
  #   lambda { @sample.schema = [{:name => :foobar, :has_many => {:associations => [:foo, :bar]}}] }.should raise_error(IMW::SchemaError)
  # end

  # it "should accept a valid schema" do
  #   @sample.schema = [:foo, :bar, :baz]
  #   @sample.schema.should == [{:name => 'foo'}, {:name => 'bar'}, {:name => 'baz'}]
  # end

  # describe "guessing a schema" do

  #   Dir[File.join(IMWTest::DATA_DIR, 'formats/delimited/with_schema/*')].each do |path|
  #     it "should correctly guess that with_schema/#{File.basename(path)} has headers in its first row" do
  #       IMW.open(path).headers_in_first_line?.should == true
  #     end
  #   end

  #   Dir[File.join(IMWTest::DATA_DIR, 'formats/delimited/without_schema/*')].each do |path|
  #     it "should correctly guess that without_schema/#{File.basename(path)} does not have headers in its first row" do
  #       IMW.open(path).headers_in_first_line?.should == false
  #     end
  #   end

  #   it "should automatically set the headers on a source with guessed headers" do
  #     resource = IMW.open(Dir[File.join(IMWTest::DATA_DIR, 'formats/delimited/with_schema/*')].first)
  #     resource.guess_schema!
  #     resource.delimited_options[:headers].class.should == Array
  #     resource.schema.should_not be_empty
  #   end

  # end
  
end
