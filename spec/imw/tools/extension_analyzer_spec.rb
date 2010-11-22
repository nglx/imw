require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Tools::ExtensionAnalyzer do

  before do
    class Analyzer
      attr_accessor :dir, :resources
      include IMW::Tools::ExtensionAnalyzer
      def initialize dir
        self.dir = File.expand_path(dir)
        @resources = IMW.open(self.dir).all_resources
      end
      def total_size
        @total_size ||= resources.map(&:size).inject(0) { |e, sum| sum += e }
      end
    end
  end

  describe 'working with an empty directory' do
    before do
      @analyzer = Analyzer.new(IMWTest::TMP_DIR)
    end

    %w[most_common_extension_by_count most_common_extension_by_size most_common_extension].each do |method|
      it "should return 'flat' when asked for its '#{method}'" do
        @analyzer.send(method).should == 'flat'
      end
    end
    
    %w[extension_counts normalized_extension_counts extension_sizes normalized_extension_sizes].each do |method|
      it "should return an empty hash when asked for its '#{method}'" do
        @analyzer.send(method).should == {}
      end
    end
  end

  describe 'working with files that lack extensions' do
    
    before do
      @dir = File.join(IMWTest::TMP_DIR, 'ext_dir')
      FileUtils.mkdir_p(@dir)

      @f1  = "foobar1"
      @f2  = "foobar2"
      @f3  = "foobar1"
      @files = [@f1, @f2, @f3]
      
      @files.each do |basename|
        IMWTest::Random.file File.join(@dir, basename)
      end
      
      @analyzer = Analyzer.new(IMWTest::TMP_DIR)
    end

    %w[most_common_extension_by_count most_common_extension_by_size most_common_extension].each do |method|
      it "should return 'flat' when asked for its '#{method}'" do
        @analyzer.send(method).should == 'flat'
      end
    end
  end
  
  describe 'working with a directory of files' do
    before do
      @dir = File.join(IMWTest::TMP_DIR, 'ext_dir')
      FileUtils.mkdir_p(@dir)

      @csv1  = "foobar1.csv"
      @csv2  = "foobar2.csv"
      @xml  = "foobar1.xml"
      @txt  = "foobar1.txt"
      @files = [@csv1, @csv2, @xml, @txt]
      
      @files.each do |basename|
        IMWTest::Random.file File.join(@dir, basename)
      end

      def bloat basename
        File.open(File.join(@dir, basename), 'a') do |f|
          1000.times do
            f.write( 'hello ' * 100)
          end
        end
      end

      @analyzer = Analyzer.new @dir
    end

    describe "working with extension counts" do
      it "should be able to return counts by extension" do
        @analyzer.extension_counts.should == {'xml' => 1, 'txt' => 1, 'csv' => 2 }
      end

      it "should be able to return the most common extension by count" do
        @analyzer.most_common_extension_by_count.should == 'csv'
      end

      it "should be able to calculate extension weighted by number of files" do
        @analyzer.normalized_extension_counts.should == { 'csv' => 0.5, 'xml' => 0.25, 'txt' => 0.25 }
      end
    end

    describe "working with extension sizes" do
      it "should be able to calculate extension sizes" do
        csv_size = File.size(File.join(@dir, @csv1)) + File.size(File.join(@dir, @csv2))
        xml_size = File.size(File.join(@dir, @xml))
        txt_size = File.size(File.join(@dir, @txt))
        @analyzer.extension_sizes.should == { 'csv' => csv_size, 'xml' => xml_size, 'txt' => txt_size }
      end

      it "should be able to return the most common extension by size" do
        bloat @txt
        @analyzer.most_common_extension_by_size.should == 'txt'
      end

      it "should be able to calculate extension sizes" do
        csv_size = File.size(File.join(@dir, @csv1)) + File.size(File.join(@dir, @csv2))
        xml_size = File.size(File.join(@dir, @xml))
        txt_size = File.size(File.join(@dir, @txt))
        total_size = csv_size + xml_size + txt_size
        @analyzer.normalized_extension_sizes.should == { 'csv' => csv_size.to_f / total_size.to_f, 'xml' => xml_size.to_f / total_size.to_f, 'txt' => txt_size.to_f / total_size.to_f }
      end
    end

    describe "determining the most common extension" do

      it "should obviously return an extension if it is the most common by count as well as the most common by size" do
        bloat @csv1
        @analyzer.most_common_extension.should == 'csv'
      end

      it "should return the most common extension by count if the count fraction is half or greater and the size fraction is less than half" do
        bloat @txt
        bloat @xml
        @analyzer.most_common_extension.should == 'csv'
      end

      it "should return the most common extension by size if the size fraction is half or greater and the count fraction is less than half" do
        # need to add an xml file
        @new_xml = File.join(@dir, 'xml2.xml')
        IMWTest::Random.file(@new_xml)
        bloat @txt
        @analyzer = Analyzer.new @dir
        @analyzer.most_common_extension.should == 'txt'
      end

      it "should return the most common extension by size if no other conditions are met" do
        bloat @txt
        @analyzer.most_common_extension.should == 'txt'
      end
      
    end
  end
end
