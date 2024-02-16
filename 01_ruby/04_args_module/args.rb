# 次の条件を満たすクラス、Argsを作成してください
# 特に指定のない限り、作成するメソッドはすべてpublicです
#
# 1.
#   3つの引数を取るメソッド `calc` を作成してください
#   1つ目の引数の文字列を、2つ目の引数の数だけ並べ、その文字列を3つ目の引数の数に等しい長さの配列の要素として新しい配列を作成し返してください
#   ただし、3つ目の引数はオプショナルとし、省略した場合は2つ目の引数と同じ数字を利用します
#   例： calc("hoge", 2, 3) # => ["hogehoge", "hogehoge", "hogehoge"]
#
# 2.
#   2つのキーワード引数arrayとkeywordを取るメソッド、 `count_object` を作成してください。
#   arrayの各要素の中に、keywordが何回現れるかを返してください
#   ただし、arrayはデフォルトで空の配列が与えられるものとします
#
# 3.
#   2つのキーワード引数benriとsugoiを取るメソッド、 `configure` を作成してください
#   また、2つのキーワード引数の他に、オプショナルでキーワード引数を取得できるようにしてください
#   オプショナルなキーワード引数のうち、 `c_` で始まるキーワードが渡された場合には、benriとsugoiと同様の挙動をしてください。ただし、キーワードを扱うときに `c_` の文字列は取り除いてください。
#   `c_` で始まるオプショナルなキーワードを扱うときは、文字列でソートした順に扱ってください。
#   benriとyabaiの内容を、 "Configure 'keyword' as 'value'" の文字列で出力してください。keywordはキーワード、valueはキーワードに渡された値でそれぞれ埋めてください。
#   `c_` で始まるキーワードに関しては、この二つの後に出力してください
#
#   例： configure(benri: "yabai", sugoi: "oniyabai", c_hoge: "uhyo-", c_foo: "iihanashi")
#        # =>
#         Configure 'benri' as 'yabai'
#         Configure 'sugoi' as 'oniyabai'
#         Configure 'foo' as 'iihanashi'
#         Configure 'hoge' as 'uhyo-'

class Args
  def calc(str, str_repeat_num, replicate_num = str_repeat_num)
    repeated_str = str.to_s * str_repeat_num
    3.times.map{|_| repeated_str}
  end

  def count_object(array: [], keyword:)
    array.count(keyword)
  end

  def configure(benri:, sugoi:, **options)
    puts configuration_repr("benri", benri)
    puts configuration_repr("sugoi", sugoi)
    options.filter{|k, v|
      k.start_with?("c_")
    }.map{|k, v|
      [k.slice(2..-1), v]
    }.sort.each{|k, v|
      puts configuration_repr(k, v)
    }
  end

  private
  def configuration_repr(key, val)
    "Configure '%s' as '%s'" % [key, val]
  end
end
