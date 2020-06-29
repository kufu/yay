References
===

まずすべての学習の前に、Ruby及びRailsに関して調べごとをする方法をお伝えします。

# 公式のドキュメント

[オブジェクト指向スクリプト言語 Ruby リファレンスマニュアル](https://docs.ruby-lang.org/ja/latest/doc/index.html)

Rubyのことをなにか調べたいと思ったら、まず最初に見るべきはここです。
ここには、Rubyの言語としての仕様やAPIリファレンスがだいたいすべて書かれています。
Rubyの基本的な文法や制御構文などに関しても、ここを読むことで一通り理解ができると思います。

その中でも、特に利用すると思われるのが組み込みライブラリの一覧です。
[library builtin (Ruby 2.7.0 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/library/_builtin.html)

ArrayやHashやString、ClassやModuleやObjectといったとても良く使うクラスやモジュールが一覧で纏められていて、それらのメソッドを調べることができます。
また、継承ツリーも各クラスやモジュールの先頭に書かれているので、Rubyの大筋の構成を把握することにも役立ちます。

[ライブラリ一覧 (Ruby 2.7.0 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/library/index.html)

組み込みではない、標準のライブラリ（使用する時にrequireする必要がある）のページでは、rakeやcsvやopen3、cgiやnet/httpやsecurerandomなどがよく利用されると思います。
Webに関する機能や、ファイルに関する機能はここを参照すると良いと思います。


# るりまサーチ

[最速Rubyリファレンスマニュアル検索！ | るりまサーチ](https://docs.ruby-lang.org/ja/search/)

Rubyを書いていると、よく「このメソッドって何のオブジェクトのメソッドなの？」という疑問によくぶち当たります。
例えば、次のコード内で使われている `any?` は何のオブジェクトのメソッドでしょうか？

```ruby
[1,2,3,4].any? { |num| num > 3 } #=> true
```

レシーバは配列なので、Arrayでしょうか？　いいえ、 `any?` はEnumerableモジュールのメソッドです。
これは非常にシンプルな例で、Arrayのドキュメントを見に行っても書いてあるので、実は困ることはそんなにありません。

```ruby
require 'csv'
```

`require` も、当然メソッドです。このように、突然出てくるメソッドはどこに生えているのか？
Rubyになれれば探し方もわかってきますが、それまではまずはるりまで検索するのが一番カンタンです。

# Ruby API

[Ruby API (v2.7)](https://rubyapi.org/)

高速な検索とJavaDocみたいな左ペインが特徴のオシャレドキュメントです。
[Ruby on Rails API](https://api.rubyonrails.org/) のように各メソッドの解説にて実際のRubyの実装にジャンプできるので、実装に興味のある人にはとても便利です。

# Dash for macOS
[Dash for macOS - API Documentation Browser, Snippet Manager - Kapeli](https://kapeli.com/dash)

同上
