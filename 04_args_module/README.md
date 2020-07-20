Arguments, Module
===

# メソッド定義時の引数

> 参考 :
> かんたんRuby 4-02 P117
> かんたんRuby 8-01 P223
> かんたんRuby 8-03 P227
> かんたんRuby APPENDIX P414

Rubyにおけるメソッドの引数定義は非常に複雑です。普通に使っていれば問題ないですが、一度凝ったことをしようとすると一気にわけのわからないことになります。
ここでは全体像をお伝えしますが、Rubyの世界に入門するために理解すべきことは少ないので、確実に基礎を抑えておきましょう。

公式ドキュメントに書かれているRubyのメソッド定義はこのようなシグネチャです。

```
def メソッド名 ['(' [arg0 ['=' default0]] ... [',' '*' rest_args [, post ...]] [',' key1: [val1]] ... [',' '**'kwrest] [',' '&' block_arg]`)']
```

分かりづらいですが、先頭から次のことを表しています

- 引数
- デフォルト式の付いた引数
- 可変長引数
- 可変長引数の後ろでキャプチャする引数（デフォルト式は付けられない）
- キーワード引数
- 未定義のキーワード引数
- ブロック引数

これらはいずれも省略可能ですが、上記の順序を守る必要があります。

これらの中から、一般によく用いられるのは引数、キーワード引数、ブロック引数です。

## 引数とデフォルト式

下記に示すのは、最も一般的な引数とデフォルト引数の形です。

```ruby
def foo(a, b = 60)
  puts a
  puts b
end

foo(10)
#=>
# 10
# 60

foo(10, 40)
#=>
# 10
# 40
```

デフォルト式の付いている引数は、可変長引数が現れるまでは自由に順序を決めることもできます。
面白い機能ではありますが、基本的にユーザーコードでバグを引き起こすことが多いので、特別な理由がない限りは避けましょう。

```ruby
def foo(a, b = 20, c)
  puts a
  puts b
  puts c
end

foo(1, 3)
# =>
# 1
# 20
# 3
```

また、デフォルト式は当然式なので、式を書けます。

```ruby
def foo(a, b = a + 20)
  puts a
  puts b
end

foo(10)
# =>
# 10
# 30
```

## キーワード引数

キーワード引数は、デフォルト式が許容される引数のあとに指定します。この順序を変えることはできません。
また、キーワード引数にもデフォルト式は使用できます。

```ruby
def foo(a:, b:, c: a)
  puts a
  puts b
  puts c
end

foo(a: 1, b: 2)
# =>
# 1
# 2
# 1
```

### キーワード引数とハッシュオブジェクト引数

Ruby2.0から導入されたキーワード引数は、ハッシュの引数を最後に指定することで、ハッシュをキーワード引数に変換することが可能でした。 しかし、この挙動は複雑でバグの温床になるため、Ruby3.0からは削除される予定です。
それに先駆けて、Ruby2.7ではこの挙動を使った場合に警告が出るようになりました（いろいろあって2.7.2からは出なくなりますが、依然としてRuby3.0で削除されることに変わりありません）

キーワード引数との変換の話に入るまえに、Ruby特有の機能であるハッシュ引数について説明します。

```ruby
def foo(a, b)
  puts a
  puts b
end

foo("str", foo: 1)
# =>
# "str"
# {:foo=>1}
```

Rubyには、引数の最後に渡すハッシュオブジェクトは、ブラケット（`{}` ）を省略できるというルールがあります。そのルールに則ると、以下の二つのメソッド呼び出しは等価です。

```ruby
# この二つの呼び出しは等しい
foo("str", foo: 1, hoge: 2, piyo: 3)
foo("str", { foo: 1, hoge: 2, piyo: 3 })
```

問題は、このfooメソッドがどのようなシグネチャかに依ります。次のように宣言されている場合は、呼び出し時にキーワード引数を渡すことで、キーワード引数を暗黙的にハッシュに変換する処理が入ります。

```ruby
def foo(a, b)
  puts b.class
end

foo("str", foo: 1, hoge: 2, piyo: 3)
# => Hash
```

一方で、次のように宣言されている場合は、呼び出し時に明示的にハッシュを渡すことで、ハッシュをキーワード引数に暗黙に変換する処理が入ります。


```ruby
def foo(a, foo:, hoge:, piyo:)
  puts foo
  puts hoge
  puts piyo
end

foo("str", { foo: 1, hoge: 2, piyo: 3 })
# =>
# 1
# 2
# 3
```

もちろん、次のような宣言と呼び出しの組み合わせであれば、問題は特に起こりません。

```ruby
# ハッシュを期待する引数に、明示的にハッシュを渡している
def foo(a, b)
  puts b.class
end

foo("str", { foo: 1, hoge: 2, piyo: 3 })
# => Hash
```

```ruby
# キーワード引数を期待する引数に、明示的にキーワード引数を渡している
def foo(a, foo:, hoge:, piyo:)
  puts foo
  puts hoge
  puts piyo
end

foo("str", foo: 1, hoge: 2, piyo: 3)
# =>
# 1
# 2
# 3
```

キーワード引数を使えなかったRuby1.8以前では、長らくメソッド最後の引数としてハッシュを渡す挙動を、キーワード引数のように扱ってきた歴史があります。
現在では、Ruby2.0から導入されたキーワード引数を利用するほうが、記述的にも挙動的にも自然になっているため、キーワード引数を使いましょう。

#### ハッシュオブジェクト引数の使いみち

その一方で、引数の最後に暗黙的に渡されるハッシュオブジェクトには、一つの有効な使い方があります。それは、キーワード引数にするにはあまりに冗長なハッシュオブジェクト、例えばConfigure系のメソッドで使われるオプションの値の引き回しに使われます。
この機能も、キーワード引数の未定義引数として `**kwrest` という引数で受け取ることができますが、未だに多くのライブラリなどで使われているイディオムなので、覚えておく価値はあります。

```ruby
def configure(required1 = required1_default, required2 = required2_default, options = {})
  configure_required1(required1)
  configure_required2(required2)
  configure_option1(options[:option1]) if options[:option1]
  configure_option2(options[:option2]) if options[:option2]
  configure_option3(options[:option3]) if options[:option3]
  configure_option4(options[:option4]) if options[:option4]
  configure_option5(options[:option5]) if options[:option5]
  # and more...
end

configure("hoge","foo", option3: "piyo")
```

この様に、オプショナルな設定でありキーワード引数として表現するには量が膨大なときなどに利用されます。ただし、この書き方はキーワード引数と共存させることができないため、キーワード引数を使いたい場合は `**` で引数を宣言する必要があります。

```ruby
def configure(required1: required1_default, required2: required2_default, **options)
  configure_required1(required1)
  configure_required2(required2)
  configure_option1(options[:option1]) if options[:option1]
  configure_option2(options[:option2]) if options[:option2]
  configure_option3(options[:option3]) if options[:option3]
  configure_option4(options[:option4]) if options[:option4]
  configure_option5(options[:option5]) if options[:option5]
  # and more...
end

configure(required1: 1,  required2: 4, option2: 4) # valid
configure(option3: "foo") # valid
configure({ option5: "piyo" }) # warning appear on Ruby2.7
```

## ブロック引数

ブロック引数は、必ず引数リストの最後に位置します。また、省略されても渡すことは可能ですが、理由がなければブロックを引数に取るメソッドはブロックを引数にキャプチャしましょう。

```ruby
# 判断可能だけど、キャプチャしようね
def foo
  puts block_given?
end

foo #=> false
foo { } # =>true


# キャプチャした場合も同じ挙動です
def foo(&blk)
  puts block_given?
end

foo #=> false
foo { } # =>true
```

# モジュールとクラスの違い

> 参考 : かんたんRuby 10-01 P280

Rubyには、クラスの他にモジュールという非常によく似た機能を持つオブジェクトが存在します。双方の違いは、大きく分けるとインスタンス化可能か否かと、インクルード可能か否かだけです。

## 名前空間としてのモジュール

モジュールの用途の一つとして、名前空間を区切るというものがあります。Gemを作成するときには、まずトップレベルでGemの名前のモジュールを作成して、他のコードを汚染しないようにします。

```ruby
require 'kinoppyd_sugoi_benri/version'

module KinoppydSugoiBenri
  class Error < StandardError; end
  # Your code goes here...
end

require 'kinoppyd_sugoi_benri/sugoi_string'
```

モジュールで名前空間を宣言し、Gemに関わるコードを全て名前空間の下に置くことで、他のGemとの名前の衝突を回避します。
`KinoppydSugoiBenri` の名前空間の中で `SugoiString` を提供したい場合は、次のように宣言します。

```ruby
class KinoppydSugoiBenri::SugoiString
end
```

多くの場合は、ディレクトリ構成とモジュール構成は一致します。例えば、うえの名前空間の場合は、次のようにディレクトリを作成します。

```shell
└── kinoppyd_sugoi_berni
    ├── sugoi_sgring
    │   └── ext.rb
    ├── sugoi_string.rb
    └── version.rb
```

気をつける点としては、モジュールはインスタンス化できないので、上の例での `sugoi_string.rb` と `sugoi_string/ext.rb` などのように、名前空間ではあるがインスタンス化も必要な場合は、モジュールでなくクラスを使う必要があります。
また、存在しない名前空間を `::` でつないでしまうと、例外を発生させます（Railsの環境下では、暗黙的にクラスを作成してしまいます）。例えば、次のような例です。

```ruby
# Hogeが宣言されていない状態で
class Hoge::Foo; end # => NameError (uninitialized constant Hoge)
```

これは、requireの順序などで事故を起こします。例えば、名前空間Hogeを宣言するよりも先に `class Hoge::Foo` を読んでしまうと、エラーが発生します。
名前空間のロードは、優先的に行いましょう。


## mixin

> 参考 : かんたんRuby 10-03 P285

モジュールにできて、クラスにできない機能の一つにmixinがあります。インクルードとして冒頭で紹介した機能です。

```ruby
module Benri
  def sugoi
    puts "sugoi"
  end
end

class Foo
  include Benri

  def monosugoi
    sugoi
  end
end

Foo.new.monosugoi # => "sugoi"
```

モジュールの中で宣言したメソッドは、クラスにincludeすることにより、そのクラスのインスタンスメソッドとして使用することができます。
また、クラスメソッドとして追加したい場合には、extendを使います。

```ruby
module Benri
  def sugoi
    puts "sugoi"
  end
end

class Foo
  extend Benri

  def monosugoi
    sugoi
  end
end

Foo.monosugoi # => "sugoi"
Foo.new.monosugoi # => 例外が発生する、sugoiはFooのインスタンスメソッドではないため
```

## クラス変数

> 参考 : かんたんRuby 9-03 P249

この名前を聞くとつい使いたくなるかもしれませんが、protectedと同じで使ってはいけない、今すぐ名前を忘れろ。以上です。

以上ですと言うと取り付く島もないので、クラス変数に関して簡単に説明すると、定義したクラスとそのクラスのインスタンス、そしてそのクラスを継承したすべてのクラスとインスタンス全てから制限なくアクセスできる共有の変数です。クラスのシングルトン変数という言い方が最も近いかと思いますが、どこからでも書き換えが可能なので非常に危険です。
クラス変数は、 `@@` というプレフィックスを利用します。実際にこれが必要になるケースはほとんど無く、大体の場合は次のクラスインスタンス変数で解決できます。

クラス特有のシングルトン変数が欲しいけれど、クラスのインスタンスから直接アクセスできないようにしたい場合は、クラスインスタンス変数を使用しましょう。
クラスインスタンス変数とは、クラスオブジェクトの変数です。すでに何度も出てきた話ですが、Rubyにおいてクラスもオブジェクトです。そのため、クラスオブジェクトも通常のクラスと同じ様に、インスタンス変数を持つことができます。
クラス変数とはスコープが違うため、クラスインスタンス変数はそのクラス”の”オブジェクトからは参照することができません。必ず”クラスオブジェクト”から参照する必要があります。
また、クラスインスタンス変数は、そのクラスを継承したクラスからも参照することはできません。クラスオブジェクトの変数は、継承先に引き継がれないからです。

```ruby
class Yabai
  @@class_val

  def a
    @@class_val # アクセスできる
  end

  def self.b
    @@class_val # アクセスできる
  end
end

class Safe
  @class_ins_val

  def a
    @class_ins_val # アクセスできない
  end

  def self.b
    @class_ins_val # アクセスできる
  end
end
```
