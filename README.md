# Yay!

このテキストは、Web開発の経験があるけれど、RubyとRailsにはまだ慣れていない方々に向けて作成されたものです。
SmartHRでは、現在多くのプロダクトのバックエンドがRailsによって書かれています。すなわち、RailsのスキルはSmartHRのエンジニアに必須です！
しかし、Railsを深く理解するのはとても難しいです。なぜなら、Railsを理解するためにはまずRubyを理解する必要があるからです。
どの言語、どのWAFでも同じですが、そのWAFを使いこなすためには言語の特性を知り、WAFの動きを頭の中で納得することが重要です。

前半パートでは、まずRailsを理解するためのRuby講座があります。そして後半パートでは、Railsを理解していきます。
このテキストを終える頃には、あなたはSmartHRのRails戦士です！
Yay!

## 開発環境について

- Ruby 2.7 以上（2.6などでも動くはずですが、特別な理由がない限り最新のバージョンを利用しましょう）
  - Bubdlerは2系のものを準備してください（Ruby 2.7であれば標準でBundler 2系がインストールされています）
- Rails 6.0 以上（予定）

## テストの実行方法について

rakeコマンドを通じてテストを実行する設計になっています。

```sh
% bundle install
```

で必要なライブラリをインストールしてから、rakeを実行します。本リポジトリではテストに対して実装が行われていない設計になっているため、テストが大量にfailしますが正しい状態です。

```sh
% bundle exec rake
bundle exec rake
Run options: --seed 64799

# Running:

EEEFEFEEEEEEEEEEEE

Finished in 0.004522s, 3980.5396 runs/s, 442.2822 assertions/s.
    :
    :
Tasks: TOP => default => test
(See full trace by running task with --trace)
```

特定のディレクトリのみテストを実行したい場合はTEST環境変数を利用します。

```sh
% bundle exec rake TEST=test/03_private_symbol/*.rb  
```

## Rubyのインストール方法

新しいRubyが一番良いRubyなのでrbenvを使って新しいRubyを用意しておきましょう

### Rubyインストール準備

`rbenv`をインストールします

- https://github.com/rbenv/rbenv#installation
  - インストール方法に依らず、.bash_profileなどに設定を追加する必要があります（https://github.com/rbenv/rbenv#basic-github-checkout の `3.`の手順です）
  - `rbenv init`を実行すると、どのファイルに何を記載するか出力してくれるので、そこを参考にして`eval "$(rbenv init -)"`を記載しましょう
- brew以外の方法でrbenvをインストールした場合はruby-buildのインストールも行う必要があります
  - https://github.com/rbenv/ruby-build#installation
- ProTip
  - 手動でrbenvをインストールしている勢は`rbenv-update`も導入しておくと、`rbenv update`でインストールリストの更新ができて便利だよ
  - https://github.com/rkh/rbenv-update

### Rubyのインストール

インストールできるバージョンを確認しましょう。

```sh
% rbenv install -l
2.5.8
2.6.6
2.7.1
jruby-9.2.12.0
maglev-1.0.0
mruby-2.1.1
rbx-5.0
truffleruby-20.1.0

Only latest stable releases for each Ruby implementation are shown.
Use 'rbenv install --list-all' to show all local versions.
```

rbenvでは、いわゆる普段使う`Ruby`（区別するためにCRubyやMRIなどと呼ばれることもあるよ）以外にJRubyやmrubyなどもインストールできます。
ここでは普通のRubyを使うため、プリフィックスに何も記載されていないものが対象のRubyです。

今回は最新バージョンである2.7.1を利用します。

```sh
% rbenv install 2.7.1
```

ビルドが走るのでコーヒーでも入れてのんびり待ちます。
終わったらインストールしたRubyをデフォルトで使用するRubyに指定します。
（この瞬間だけ任意のバージョンを利用したい！というときは`global`の代わりに`shell`を使うと良いです）

```sh
% rbenv global 2.7.1
```

rbenv versionsを使うと現在のRubyのインストール・使用状況を確認できます。今回は2.7.1を指定したので、2.7.1に`*`がついていれば大成功です。
（作業ディレクトリに`.ruby-version`などがあるとそちらを優先するため、思った通りのバージョンにならない場合はそちらも確認しましょう）

```sh
% rbenv versions
  system
  2.5.7
  2.6.6
* 2.7.1 (set by /Users/***/.rbenv/version)
```

最後に、rubyコマンドでも正しいバージョンが利用されているか確認しましょう。

```sh
% ruby -v
ruby 2.7.1p83 (2020-03-31 revision a0c7c23c9c) [x86_64-darwin19]
```
