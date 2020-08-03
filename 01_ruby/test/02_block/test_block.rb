require 'test_helper'
require 'block'

class TestBlock < MiniTest::Test
  class ::LearnBlock
    def initialize; @touch = nil; end
    def unknown_number
      @touch ? raise : @touch = 42
    end
  end

  def instance
    LearnBlock.new
  end

  def test_ext_sum_num
    expects = 110
    res = instance.ext_sum(1, 10) do |n|
      n * 10
    end
    assert_equal expects, res
  end

  def test_ext_sum_str
    expects = 'abababababababababab'
    res = instance.ext_sum('a', 'b') do |s|
      s * 10
    end
    assert_equal expects, res
  end

  def test_ext_sum_nil
    res = instance.ext_sum(1, 2) do |n|
      nil
    end
    assert_nil res
  end

  def test_ext_sum_not_receive_block
    assert_equal 11, instance.ext_sum(5, 6)
  end

  def test_search_unknown_with_zero
    arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    expect = [3, 8]
    assert_equal expect, instance.search_unknown(arr, 0)
  end

  def test_search_unknown
    arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    expects = [1, 6]
    assert_equal expects, instance.search_unknown(arr, 2)
  end
end
