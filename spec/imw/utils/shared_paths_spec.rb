require File.join(File.dirname(__FILE__),'../../spec_helper')

share_examples_for "an object that manages paths" do
  before do
    @path_manager.add_path :testing, '/testing'
    @path_manager.add_path :first,   '/1'
  end
  
  it 'returns a string when given a string' do
    @path_manager.path_to('hi').should == 'hi'
  end

  it 'returns a path when given a registered symbol' do
    @path_manager.path_to(:testing).should == '/testing'
  end

  it 'raises an error when given a unregistered symbol' do
    lambda { @path_manager.path_to(:foobar) }.should raise_error(IMW::PathError)
  end
  
  it 'returns a constructed path when passed a mixture of symbols, strings, and arrays ' do
    @path_manager.path_to( [:testing, 'hi'], [[['there']]]).should == '/testing/hi/there'
  end
  
  it 'will correctly expand paths themselves defined via symbols' do
    @path_manager.add_path(:first, :testing, '1')
    @path_manager.path_to(:first).should == '/testing/1'
  end
end
