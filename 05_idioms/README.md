Idioms
===

= 式展開

ダブルクォートで囲われた文字列、コマンド文字列、正規表現の中では、 `#{expr}` の形式でexprの式を実行した結果を埋め込むことができます。

```ruby
hoge = "hoo"
"piyo #{hoge}" # => "piyo hoo"
"#{"piyo" * 3}" # => piyopiyopiyo"
```

文字列の動的生成にとても良く使うので、使いこなせるようになっておきましょう。

= %記法

> かんたんRuby APPENDIX P406

文字列リテラル、コマンド出力、正規表現リテラル、配列式、シンボルでは、 %で始まる形式の記法を用いることができます。
この中でも、Rubyでは特に配列式をよく利用します。むしろその他の%記法はほとんど使われないので、覚える必要はありません。
また、コード中で配列リテラルなどを使って文字列の配列を新しく生成しようとするときには、Rubocopによって%記法を使うように警告が出されます。
なんで警告が出るのかは、詳しい人が解説してくれると思います。

`%w` は、続く任意の非英数字で囲まれた文字列をスペースで区切り、新しく配列を作成します。
非英数字の文字列であれば何でも良いですが、慣習に従って `()` で囲むことを推奨します。`()` 以外を使うと、これも同様にRubocopによって警告が出ます。

```ruby
%w(hoge foo piyo) # => ['hoge', 'foo', 'piyo']
%w|hoge foo piyo| # => ['hoge', 'foo', 'piyo']
%w<hoge foo piyo> # => ['hoge', 'foo', 'piyo']
```

文字列の配列の作成ほどではありませんが、次によく使われるのは `%i` のシンボルの配列生成です。

```ruby
%i(hoge foo piyo) # => [:hoge, :foo, :piyo]
```

`%w` と `%i` には、それぞれ対になる `%W` と `%I` が存在します。これらの違いは、式展開とバックスラッシュ記法が有効かどうかです。

```ruby
%w(hoge #{1+1}=\s2 piyo) # => ["hoge", "\#{1+1}=\\s2", "piyo"]
%W(hoge #{1+1}=\s2 piyo) # => ["hoge", "2= 2", "piyo"]
```

= and と or は使わないでね

イディオムというより約束事ですが、Rubyにはandとorという組み込みの論理演算があります。これは&&と||と同様の動きをしますが、評価の優先度が変わります。
紛らわしいので、特別な理由がなければコードを書くときには使わないようにしましょう。

```ruby
true or false and false #  => false
# この式は、andとorの結合に優先が無いため、true or false がまずtrueと解釈され、次にtrue and falseがfalseと解釈される

true or false && false # => true
# この式は、先に優先度が高いfalse && falseが結合されfalseとなり、次にtrue or falseがtrueと解釈される
```

# setterの=もメソッドだよ

`def hoge=(foo)` と定義したメソッドは、 `hoge = "something"` として呼び出せます。
これは、末尾が `=` で終わるメソッドは、 `=` の前後にスペースを入れることが特別に許可されているからです。
また、Rubyには仕様上getter/setterというものが存在せず、すべてはユーザーが定義するメソッドです。
これらを楽に生成するために、 `attr_` 系のマクロも存在します。

```ruby
class Hoge
  # このマクロを使うと、`def hoge; @hoge; end` と `def hoge=(v); @hoge = v; end` が自動生成される。
  attr_accessor :hoge
end

hoge = Hoge.new
hoge.hoge = 1
hoge.hoge # => 1
```

attr_accessorの他に、getterだけを生成するattr_reader、setterだけを生成するattr_writerもあります。

= ||=

> 参考 : かんたんRuby 2-05 P086

`||=` は、Rubyで特に頻出するイディオムです。式そのものの意味は、 `+=` などと同じで、左辺の値に対して右辺を演算子で評価し、その結果を左辺に代入します。
つまり、 `a ||= b` は、 `a = a || b` と同等です。このイディオムは、変数の初期化に用いられます。

```ruby
num = 1
num += 2
num # => 3

hoge = nil
hoge ||= 1
hoge # => 1
```

Rubyではメソッドの最後に評価された式がメソッドの戻り地になります。そのため、次のようなイディオムが頻出します。

```ruby
def memonized_hoge
  @hoge ||= initial_hoge
end
```

このメソッドは、初めて呼び出されたときは `initial_hoge` を評価し、その結果を `@hoge` に代入し、そして `@hoge` の内容を戻り値として返します。
そして、このメソッドが2回目以降に呼ばれるときは、 `initial_hoge` は評価されず、 `@hoge` の値が返されます。
動的な初期化が必要だけれども、2回目以降はその結果をキャッシュしたいときなどによく目にする表現です。

= &:

> 参考 : かんたんRuby APPENDIX P417

`&:` は、ブロックの引数に対して特定のメソッドを呼び出すだけのブロックを省略するときに利用します。

```ruby
[1, 2, 3].map { |num| num.even? } # => [false, true, false]
[1, 2, 3].map(&:even?) # => [false, true, false]
```

上の二つの式は同じ動きをします。
`&:` は、実際にはシンボルのProc変換を使った非常に理解に苦しむ暗黙の処理が発生していますが、難しすぎるので理解する必要はありません。
実用的には、Enumrableのブロックで引数に対して一つのメソッドを呼び出したい場合に使える省略表記だと思ってください。

= Struct

名前の通り、構造体です。複数の値に名前をつけて保持するクラスを、簡単に宣言できます。

```ruby
Cat = Struct.new(:name, :age)
c = Cat.new("sensei", 100) # => #<struct Cat name="sensei", age=100>
c.name # => "sensei"
c.age # => 100
```

引数は宣言時の順番で渡す必要があるので直感的ではありませんが、keyword_initを使うとキーワード引数として渡せるので途端に最高になります。

```ruby
Person = Struct.new(:name, :age, keyword_init: true)
Person.new(age: 33, name: 'kinoppyd') # => #<struct Person name="kinoppyd", age=33>
```

# unless

ifの逆の意味を持つ組み込み演算子です。

```ruby
unless 1 == 2
  # ここを通る
else
  # こっちは通らない
end

puts "hoge" unless 1 == 2 # => "hoge"
```

unlessは、式を評価した結果がfalse（つまりfalseかnil）であった場合に続く式を評価します。
多くは、ガード節として使われます。また、unlessには複雑な評価式を渡さないようにしましょう。バグの温床になります。

```ruby
# わけがわからなくなるのでやめましょう
puts "hoge" unless (readable? && writable?) || admin? && owner?
```

= 範囲式とRange

> 参考 : かんたんRuby 7-03 P199

Rubyでは、整数の範囲を表現するRangeというクラスがあります。リテラルは `1..10` のように、ドット2つで1から10まで、`1...10` のようにドット3つで1から9までの整数の集合になります。

```ruby
(1..10).to_a # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
(1...10).to_a # => [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

これが最も用いられるのは、配列の部分取得を行うときです。

```ruby
%(hoge foo piyo boom)[1..2] # => ['foo', 'piyo']
```

`Array#[]` にRangeを渡すとき、末尾に負数nが入る場合、それは末尾からn番目として扱われます。

```ruby
%(hoge foo piyo boom)[1..-1] # => ['foo', 'piyo', 'boom']
%(hoge foo piyo boom)[1..-2] # => ['foo', 'piyo']
```

= begin...rescue

Rubyにおける例外は、beginとrescueのブロックで表現されます。

```ruby
begin
  raise('死') # 例外クラスを明示せずにraiseすると `RuntimeError` が発生する（例外クラスを省略したraiseはオススメはしません）
  puts "生きてるよ"
rescue
  puts "死んだよ"
end

# => "死んだよ"
```

特定のエラーを選択してrescueも可能です。

```ruby
begin
  raise(RuntimeError)
  puts "生きてるよ"
rescue RuntimeError => e
  puts "なんか死んだよ"
rescue
  # RuntimeError以外の例外が飛んだらここにくる
  puts "死んだよ"
end

# => "なんか死んだよ"
```
rescue節は例外クラスを`rescue RuntimeError, ArgumentError => e`のように複数指定することもできます。

メソッド全体をbegin〜rescueで囲いたい場合は、メソッド定義などの末尾にbeginなしのrescueを宣言することもできます。

```ruby
def hoge
  something
rescue
  puts "death"
end
```

また、例外クラスを明示しないrescueが捕捉できるのは、StandardErrorのサブクラスのみです。すべての例外クラスの始祖はExceptionクラスですが、自分で例外を定義するときはStandardErrorクラスを継承するようにしましょう。
```suggestion
例外クラスの継承関係については以下の組み込みライブラリページにある「例外クラス」を参考にすると良いでしょう。
https://docs.ruby-lang.org/ja/latest/library/_builtin.html

```ruby
class PpydError < StandardError; end
class KinoError < Exception; end

raise PpydError # これはrescueで捕捉可能
raise KinoError # これはrescueで補足できない、普通は処理系が即死する
```
