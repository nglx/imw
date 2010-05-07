require File.dirname(__FILE__) + "/../../spec_helper"
require 'imw/dataset/workflow'
describe IMW::Workflow do

  before do
    @dataset = IMW::Dataset.new :testing
  end

  it "should dynamically define methods for each workflow step" do
    @dataset.workflow_steps.each do |step|
      @dataset.respond_to?(step).should be_true
    end
  end

  describe "initializing workflow" do
    it "should not make any directories if no tasks are invoked" do
      @dataset.path_to(:root).should_not contain(*@dataset.workflow_dirs.map(&:to_s))
    end

    it "should only make directories once a task is invoked" do
      @dataset[:initialize].invoke
      @dataset.path_to(:root).should contain(*@dataset.workflow_dirs.map(&:to_s))
    end
  end

  describe "cleaning workflow directories" do
    it "should clean without error even if there's nothing to clean" do
      @dataset[:clean].invoke
      @dataset.path_to(:root).should_not contain(*@dataset.workflow_dirs.map(&:to_s))
    end

    it "should remove workflow directories when invoked" do
      @dataset[:initialize].invoke
      IMWTest::Random.file(@dataset.path_to(:ripd, 'foobar.txt')) # put a file in
      @dataset[:clean].invoke
      @dataset.path_to(:root).should_not contain(*@dataset.workflow_dirs.map(&:to_s))
    end
  end

end

