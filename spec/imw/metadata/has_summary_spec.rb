require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::HasSummary do

  before do
    class Foo
      def initialize(*args) ; @args = args ; end
      def uri ;               File.join(IMWTest::TMP_DIR, *@args) ; end
      def basename ;          File.basename(uri) ; end
      def extension ;         File.extname(@args.last || '').gsub(/^\./,'') ; end
      include IMW::Metadata::HasSummary
    end
    @foo = Foo.new('foo', 'bar.csv')
  end

  it "should build a summary from an external summary" do
    @foo.summary.should include(:uri, :basename, :extension)
  end

  it "should build a summary from an external summary and a schema when possible" do
    @foo.stub!(:schema).and_return({:foo => 'bar'})
    @foo.summary[:schema].should == {:foo => 'bar'}
  end

  it "should be able to build an external summary describing how it's situated in the world" do
    @foo.summary[:uri].should       == File.join(IMWTest::TMP_DIR, 'foo', 'bar.csv')
    @foo.summary[:basename].should  == 'bar.csv'
    @foo.summary[:extension].should == 'csv'
  end

end

