# 次の仕様を満たすクラスIdiomsを作成してください
#
# 1.
#   引数を一つ取るクラスメソッド `double` を作成してください
#   戻り値は、引数に渡した文字列を二つ連結したものを返してください e.g. "text" => "texttext"
#   ただし、文字列 "test" を引数に渡したときに限って、次の例外を発生させてください
#   例外は、StandardErrorを継承したDoubleErrorを発生させてください。例外クラスは、 `Idioms::` の下の名前空間で定義してください

class Idioms
  class DoubleError < StandardError; end

  def self.double(arg)
    if arg == "test" then
      raise DoubleError
    end
    arg.to_s * 2
  end
end
