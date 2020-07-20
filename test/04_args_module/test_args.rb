require 'test_helper'
require 'args'

class TestArgs < MiniTest::Test
  def ins
    Args.new
  end

  def test_calc
    assert_equal ["ffff", "ffff", "ffff"], ins.calc("f", 4, 3)
  end

  def test_calc_with_no_string
    assert_equal ["1111", "1111", "1111"], ins.calc(1, 4, 3)
  end

  def test_calc_with_less_arg
    assert_equal ["foofoofoo", "foofoofoo", "foofoofoo"], ins.calc("foo", 3)
  end

  def test_count_object
    assert_equal 2, ins.count_object(array: [1,3,4,2,3,6,7,8,10], keyword: 3)
  end

  def test_count_object_with_blank_array
    assert_equal 0, ins.count_object(keyword: "hoge")
  end

  def test_configure
    expects =
      "Configure 'benri' as '2'\n" +
      "Configure 'sugoi' as '1'\n"
      assert_output(expects) { ins.configure(sugoi: 1, benri: 2) }
  end

  def test_configure_with_options
    expects =
      "Configure 'benri' as '2'\n" +
      "Configure 'sugoi' as '1'\n" +
      "Configure 'yabai' as '3'\n"
      assert_output(expects) { ins.configure(sugoi: 1, benri: 2, c_yabai: 3) }
  end

  def test_configure_with_options_sorted
    expects =
      "Configure 'benri' as '2'\n" +
      "Configure 'sugoi' as '1'\n" +
      "Configure 'majide' as '4'\n" +
      "Configure 'yabai' as '3'\n"
      assert_output(expects) { ins.configure(sugoi: 1, benri: 2, c_yabai: 3, c_majide: 4) }
  end

  def test_configure_with_options_ignored
    expects =
      "Configure 'benri' as '2'\n" +
      "Configure 'sugoi' as '1'\n" +
      "Configure 'yabai' as '3'\n"
      assert_output(expects) { ins.configure(sugoi: 1, benri: 2, c_yabai: 3, majide: 4) }
  end
end
