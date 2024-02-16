# 次の要件を満たすクラス、SymbolManipulatorを作成してください
#
# 1.
# クラスメソッド `hash_key_switcher` を持ち、引数を一つ受け取ります
# 引数がハッシュのオブジェクトではない場合、何もせずオブジェクトをそのまま返します
#
# 2.
# `hash_key_switcher` は、引数のハッシュに次の操作をして、新しいハッシュを返します
#   a. 引数のハッシュのキーのうち、全てのStringオブジェクトをSymbolオブジェクトに変換し、バリューはそのまま保持します
#   b. 引数のハッシュのキーのうち、全てのSymbolオブジェクトをStringオブジェクトに変換し、バリューはそのまま保持します
#   b. 引数のハッシュのキーのうち、SymbolでもStringでもないものをSymbolオブジェクトに変換し、バリューはそのまま保持します
# すなわち、次の入力のときには、このような戻り値を期待します
# > input
#    { hoge: "foo", "piyo" => :boom, 1 => "one" }
# < output
#   { "hoge" => "foo", :piyo => :boom, :"1" => "one" }

class SymbolManipulator
  def self.hash_key_switcher(arg)
    if not arg.is_a?(Hash) then
      arg
    else
      arg.map{|k, v|
        if k.is_a?(Symbol) then
          [k.to_s, v]
        else
          [k.to_s.to_sym, v]
        end
      }.to_h
    end
  end
end
