# `railsコマンド`を触ってみよう

すでに事前準備でも少し触れていますたが、Railsで扱うコマンド群は`bin`ディレクトリに集約されています。
通常、Bundlerでgemライブラリを扱っている場合は`bundle exec rails`のようにbundlerを使ったコマンドの実行を行いますが、Railsでは`bundle exec`を利用せず、すぐに扱えるようなラッパースクリプトを用意しています。それがbinディレクトリ以下にあるコマンドで、一般的にこのようなラッパースクリプトはbinstubと呼ばれます。

Rails 6.0では次のようなbinstubが用意されています。もっともよく利用するのはrailsコマンドでしょう。

- ProTip:過去のRailsでよく使うコマンドはrailsコマンドとrakeコマンドに分かれていましたが、近年のRailsではrailsコマンドからrakeコマンドで利用するタスクを実行できるようになったため、rakeコマンドを直接扱うことは少ないでしょう
- ProTip:開発時によく使うコマンドをbinstubに集約すると、binディレクトリを見るだけでこのプロジェクトがどのようなコマンドを利用しているかわかるようになるため途中から参画したメンバーにも理解しやすくなるでしょう（たとえばrubocopなど）。

```sh
% ls -1FA bin
bundle*
rails*
rake*
setup*
spring*
webpack*
webpack-dev-server*
yarn*
```

それではrailsコマンドを触ってみましょう。`rails -h`でヘルプを出力してみます。

```sh
% ./bin/rails -h
The most common rails commands are:
 generate     Generate new code (short-cut alias: "g")
 console      Start the Rails console (short-cut alias: "c")
 server       Start the Rails server (short-cut alias: "s")
 test         Run tests except system tests (short-cut alias: "t")
 test:system  Run system tests
 dbconsole    Start a console for the database specified in config/database.yml
              (short-cut alias: "db")
  :
  webpacker:verify_install
  webpacker:yarn_install
  yarn:install
  zeitwerk:check
```

- ProTip:秘匿情報を扱うタスクとして`secret`と`credentials`が存在しますが、`secret`はRails 5.1までの機能なので、Rails 5.1にこだわりがなければ覚える必要はありません

ここで出力される内容のうち、最初に表示されるgenerateやconsoleはRails開発において基本となるコマンド群です。とくにconsoleやserverは日常的に利用するコマンドです。

一方、メインとなるコマンド以降の出力内容は旧来のrakeコマンドで利用してきたものです。引き続きrakeコマンドを使って実行することも可能ですが、「使い分けをすることが初学者へ混乱を招く」ということでrailsコマンドから利用できるようになった経緯があるため、特別な理由がなければrailsコマンドを使いましょう。

- 🙆‍♀️ `./bin/ralis stats`
- 🙅‍♀️ `./bin/rake stats`

Rakeタスク由来のコマンドのうち、よく利用するのは以下のコマンドでしょう。

- `db:xxxx` DBのテーブル情報などを更新する
  - db:create
  - db:migrate
  - db:version
- `routes` ルーティング情報を出力する
- `runner` ワンライナーや単発のスクリプトなどを実行する