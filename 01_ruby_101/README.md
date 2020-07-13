Ruby 101
===

Rubyを読む/書く時に大切な基本マインドセット

- 全てはオブジェクト
- ほとんどの計算は式
- 真偽値の考え方
- レシーバの意識


# 全てはオブジェクト　

> 参考：かんたんRuby 1-02 Rubyの特徴 P28

Rubyの世界観において、全てのものはオブジェクトです。そこに例外はありません。
文字列、配列、数値、クラス、それら全てはオブジェクトです。

```ruby
class Foo
  def foo
    "foo"
  end
end

hoge = Foo.new
```

hogeには、Fooのインスタンスが代入されます。 そして同じ様に、Fooはclassクラスのインスタンスです。
Rubyでは、`.class` メソッドを使い、オブジェクトの属しているクラスを知ることができます。

```ruby
100.class    #=> Integer
"hoge".class #=> String
{}.class     #=> Hash
Foo.class    #=> Class
```

100がIntegerクラスのインスタンスであり、"hoge"がStringクラスのインスタンスであるのと同様に、FooはClassというクラスのインスタンスであることがわかります。
Classというクラスは話がややこしいので、今ここで理解する必要はありません。ただ、すべてのものがオブジェクトであるということを理解してください。

このように、Rubyではすべてのものはオブジェクトです。書かれているコードが、何のオブジェクトなのかを常に気をつけるようにしましょう。

# ほとんどの計算は式

Rubyにおいて、ほぼすべての構文は式であり、戻り値を持ちます。

```ruby
hoge = "foo"

piyo = case hoge
       when "boom"
         1
       when "foo"
         2
       else
         3
       end

p piyo #=> 2
```

上の例では、case式が戻り値を返している様子を表しています。 `case ~ end` で囲まれたブロックが式で、その中で最後に評価された値が戻り値です。
同様に、if/unless式やクラスの定義なども戻り値を持ちます。

```ruby
hoge = "foo"
boom = if hoge == "piyo"
          10
       else
          20
       end
p boom #=> 20

fuga = class Something
          def anything
            "string"
          end
        end
p fuga #=> :anything
```

if式では、 `if ~ end` の間に最後に評価された値が、同様に classでは `class ~ end` の間に最後に評価された値が戻り値としてそれぞれ変数に代入されている様子が見えます。
classの戻り値が `:anything` というシンボルである理由は、 `def ~ end` のメソッド定義もまた式であり、定義したメソッドの名前のシンボルを戻り値とするからです。
つまり、 `class ~ end` の中で最後に評価された式が `def ~ end` であり、`def anything ~ end` の戻り値が `:anything` であるからです。

（補足 シンボルについて：シンボルは、Rubyにおいて特殊な文字表現の一つです。文字列ではなく、一つの定数の様に扱われる不変の文字列で、リテラルは文字列頭の `:` です。詳細は「かんたんRuby 5-06 シンボル」を参照してください）

この様に、Rubyではほとんどの構文が式であり、戻り値を持ちます。特にcaseやifはよく使うので、覚えておいてください。

# 真偽値の考え方

> 参考：かんたんRuby 06-01 制御構造 P163

Rubyでは、FalseClassのインスタンス(false)とnil以外は全ては真です。つまり、`1000` も `"smarthr"` も `{ a: 1 }`  もすべて真として扱われます。
偽を表現したいときには、nilかfalseを使用する以外にはありません。

（補足 nilについて：nilは、Rubyの世界におけるnullだと理解してください。なにもない状態を表現しています）

```ruby
puts "hoge" if 0 # => hoge が出力される
puts "hoge" if "" # => hoge が出力される
puts "hoge" if FalseClass # => hoge が出力される、FalseClassはClassクラスのオブジェクトなので、falseでもnilでもない

puts "hoge" if false # => hoge が出力されない
puts "hoge" if nil # => hoge が出力されない
```

また、Rubyはほとんどのものが値を返す式なので、次のようなことも起こりえます

```ruby
val = def hoge
        "hoge"
      end

puts "hoge" if val #=> hoge が出力される
```

上の例は極端ですが、ifの評価式にメソッド定義の戻り値を使用しており、メソッド定義はnilでもfalseでもない値を返すので、if文を通過します。

# レシーバの意識

Rubyでは、全てがオブジェクトです。そして、すべてのメソッドは何かしらのオブジェクトに所属しています。

（補足： 以下のように継承元を明示せずHogeクラスを定義した場合、暗黙的にObjectクラスを継承します。Objectクラスを継承することでRubyの世界で振る舞うための最低限のメソッドを有した状態のクラスが定義されます）

```ruby
class Hoge
  attr_accessor :piyo
  def foo
    @piyo ||= "piyo"
  end
end

hoge = Hoge.new
puts hoge.foo #=> piyo
```

hogeには、Hogeクラスのインスタンスが代入されており、 `hoge.foo` はhogeインスタンスのfooメソッドを呼び出しています。これは、hogeをレシーバにfooを呼び出しているといわれ、多くのオブジェクト指向言語では同じような説明がなされていると思います。
Rubyにおいては、全てがオブジェクトであり、組み込み構文以外のすべてのメソッドにはレシーバが存在します。そのことを頭において、改めて上の例を見てみましょう。
`Hoge.new` は、 `Hoge` をレシーバに `new` メソッドを呼び出しています。思い出してください、Hogeはclassクラスのインスタンスなので、当然オブジェクトです。そして、classクラスには新しいインスタンスを作成するための `new` メソッドが定義されています。

また、 `puts` もメソッドです。しかし、レシーバは何でしょう？
Rubyでは、レシーバを省略したメソッド呼び出しが可能です。そしてその場合、レシーバには自動的に `self` が利用されます。selfは、今現在の自分自身のオブジェクトです。
このルールに則れば、 `puts` は `self.puts` と等しい事がわかります。そして `self` は、このスクリプトをどうやって実行しているかによりますが、irb(REPL)などを使いトップレベルで実行すると、多くの場合は暗黙の `main` というObjectクラスのインスタンスです。
それらを念頭に置いて、改めて例を見てみましょう。

```ruby
class Hoge

  # コンテキストはclassオブジェクト、つまりHogeのクラスオブジェクトをレシーバとしたメソッド呼び出し
  # Hoge.attr_accessor(:piyo) と等しい。ただし、attr_accessorは通常プライベートメソッドなので、Hoge.attr_accesorと書くことはできない
  attr_accessor :piyo 


  # これは組み込みの式であり、メソッド呼び出しではない
  def foo
    @piyo ||= "piyo"
  end
end

# Hogeクラスをレシーバにnewメソッドを呼び出し、その結果（Hogeクラスのインスタンス）をhogeという変数に代入している
# Hogeクラスのインスタンスは、通常クラスインスタンスと呼ばれる
hoge = Hoge.new

# Hogeクラスのインスタンスをレシーバに、fooメソッドを呼び出している。そしてその結果を、 self.puts の引数にしている。
# self.puts は、通常はmainと呼ばれるObjectのインスタンスであり、Object#putsは標準出力に引数を出力する
puts hoge.foo #=> piyo
```

この様に、Rubyでは通常すべてがオブジェクトであり、メソッド呼び出しには必ずオブジェクトのレシーバが必要になります。そして、レシーバを省略した場合は、selfという現在の文脈によって変化するオブジェクトが、暗黙的にレシーバとして利用されます。
