require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))
require 'imw/recordizer/pig_recordizer'

describe SexpistolParser do
  def setup
    @parser = Sexpistol.new
  end

  it "should create nested set of arrays from s-expression with string literals" do
    ast = @parser.parse_string('(this (is (an ("s_expression"))))')
    assert_equal [[:this, [:is, [:an, ["s_expression"]]]]], ast
  end
end
