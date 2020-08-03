require 'test_helper'
require 'private'

class TestPrivate < MiniTest::Test
  def instance
    Private.new
  end

  def test_secrets_is_private
    assert_raises(NoMethodError) { instance.secrets }
  end

  def test_secrets_is_exists
    assert_equal "secret string", instance.send(:secrets)
  end

  def test_setter_key_is_private
    assert_raises(NoMethodError) { instance.key = "hoge" }
  end

  def test_setter_key_is_exists
    assert_equal "hoge", instance.send(:key=, "hoge")
  end

  def test_setter_key_sets_instance_val
    ins = instance
    expects = "ss"
    ins.send(:key=, expects)
    assert_equal expects, ins.send(:instance_variable_get, :@key)
  end

  def test_setter_string_key_with_string
    ins = instance
    expects = "special"
    ins.string_key = expects
    assert_equal expects, ins.send(:instance_variable_get, :@key)
  end

  def test_setter_string_key_with_integer
    ins = instance
    ins.string_key = 50000
    assert_equal "50000", ins.send(:instance_variable_get, :@key)
  end
end
