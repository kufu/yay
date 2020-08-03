require 'test_helper'
require 'symbol'

class TestSymbolManipulator < MiniTest::Test
  def test_return_unless_hash_given
    assert_equal "string", SymbolManipulator.hash_key_switcher("string")
  end

  def test_switch_sym_to_s
    target = { hoge: "foo", piyo: :boom }
    expects = { "hoge" => "foo", "piyo" => :boom }

    assert_equal expects, SymbolManipulator.hash_key_switcher(target)
  end

  def test_switch_s_to_sym
    target = { "hoge" => "foo", "piyo" => :boom }
    expects = { hoge: "foo", piyo: :boom }

    assert_equal expects, SymbolManipulator.hash_key_switcher(target)
  end

  def test_switch_each
    target = { hoge: "foo", "piyo" => :boom }
    expects = { "hoge" => "foo", piyo: :boom }

    assert_equal expects, SymbolManipulator.hash_key_switcher(target)
  end

  def test_convert_to_sym_other_values
    target = { 1 => "one", 1.5 => "one point half" }
    expects = { :"1" => "one", :"1.5" => "one point half" }

    assert_equal expects, SymbolManipulator.hash_key_switcher(target)
  end
end
