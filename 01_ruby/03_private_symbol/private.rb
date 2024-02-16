# 次の要件を満たすクラス、Privateを作成してください
#
# 1.
# privateメソッド `secrets` を作成してください
# `secrets` は、"secret string" という文字列を返します
#
# 2.
# privateなsetterメソッド `key=` を作成してください
# `key=` は引数を一つとり、その内容をインスタンス変数 `@key` にセットします
#
# 3.
# publicなsetterメソッド `string_key=` を作成してください
# `string_key=` は引数を一つとり、引数がStringのオブジェクトであればそのまま、そうでなければ `to_s` で文字列化して、 `key=` メソッドにその内容を渡します

class Private
  def string_key=(arg)
    self.key = arg.to_s
  end

  private
  def secrets
    "secret string"
  end

  def key=(arg)
    @key = arg
  end
end
