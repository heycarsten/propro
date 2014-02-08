require 'minitest_helper'

describe Propro::Export do
  def parse(string)
    Propro::Export.parse("#{string}\n")
  end

  def assert_parse(bash, ruby)
    assert_equal parse(bash).to_ruby, ruby
  end

  it 'parses unquoted values' do
    assert_parse \
      'export WAT_IS=neato',
      'set :wat_is, "neato"'
  end

  it 'parses single quoted values' do
    assert_parse \
      "export WAT_IS='neato'",
      'set :wat_is, "neato", lit: true'
  end

  it 'parses double quoted values' do
    assert_parse \
      'export WAT_IS="neato"',
      'set :wat_is, "neato"'
  end

  it 'parses booleans' do
    assert_parse \
      'export BOOL=yes',
      'set :bool, true'
    assert_parse \
      'export BOOL=no',
      'set :bool, false'
  end

  it 'parses integers' do
    assert_parse \
      'export INT=1234',
      'set :int, 1234'
  end

  it 'parses floats' do
    assert_parse \
      'export FLOAT=123.4567',
      'set :float, 123.4567'
  end

  it 'parses strings' do
    assert_parse \
      'export STR="super/cool.str"',
      'set :str, "super/cool.str"'
  end

  it 'parses arrays' do
    assert_parse \
      'export ARY="super cool"',
      'set :ary, ["super", "cool"]'
  end

  it 'passes comments though' do
    assert_parse \
      'export HI="yes" # comment, zro',
      'set :hi, true # comment, zro'
  end

  it 'removes tags from comments' do
    assert_parse \
      'export HI="no" # @specify comment, zro',
      'set :hi, false # comment, zro'

    assert_parse \
      'export HI="lo" # @specify',
      'set :hi, "lo"'
  end

  it 'parses @specify' do
    export = parse('export HI="yes" # @specify I am important')
    export.is_specified?.must_equal true
  end

  it 'parses @require' do
    export = parse('export HI="yes" # @require I am important')
    export.is_required?.must_equal true
  end
end
