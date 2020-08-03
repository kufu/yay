require 'test_helper'
require 'idioms'

class TestIdioms < MiniTest::Test
  def test_string_double
    assert_equal "hogehoge", Idioms.double("hoge")
  end

  def test_integer_double
    assert_equal "1111", Idioms.double(11)
  end

  def test_raise
    assert_raises(Idioms::DoubleError) { Idioms.double("test") }
  end
end
