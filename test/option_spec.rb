require 'minitest_helper'

describe Propro::Option do
  def build(*args)
    Propro::Option.new(*args)
  end

  def assert_option(*builder, bash_value)
    assert_equal build(:my_key, *builder).to_bash, "MY_KEY=#{bash_value}"
  end

  it 'handles array values' do
    assert_option %[a b c], '"a b c"'
  end

  it 'handles integer values' do
    assert_option 1234, '"1234"'
  end

  it 'handles float values' do
    assert_option 1.23, '"1.23"'
  end

  it 'handles boolean values' do
    assert_option true, '"yes"'
    assert_option false, '"no"'
    assert_option 'yes', '"yes"'
    assert_option 'no',  '"no"'
  end

  it 'handles literal values' do
    assert_option 'hello', { lit: true }, "'hello'"
  end
end
