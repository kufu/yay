# Railsツアー

`rails`コマンドや`scaffold`で生成されたコードを眺めて、Railsの世界観を身につけようの時間です

## 事前準備

本リポジトリのトップページにあるREADMEを参考にRuby 2.7系やRails 6.0系、そしてnodeなどのインストールを行っておいてください。

### サンプルアプリケーションの作成

コマンドの詳しい意味などは本編で解説するので、まずは以下のコマンドを実行してRailsアプリケーションを作成します。

`sample` 部分はアプリケーション名です。

```sh
% rails new sample --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable -d postgresql
% cd sample
```

そして、このドキュメントと同じ階層にある `docker-compose.yml` を上記のアプリケーションと同じ階層（この場合はsampleディレクトリの中）にコピーし、`docker-compose up`を実行してDocker上にDBを立ち上げます。

```sh
% docker-compose up
```

Docker上のDBに接続するため、RailsアプリケーションのDB接続情報を変更します。
config/database.ymlを編集し、default内にhostやport情報を追記します。

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost # <-- 追加
  port: 54320     # <-- 追加
  username: root  # <-- 追加
  password: root  # <-- 追加
  :
  :
```

続いて、動作確認もかねてDB上にデータベースを作成します。

```sh
% ./bin/rails db:create
```

その後、次のコマンドでPostgreSQLのターミナルへ接続できれば成功です。

```sh
% ./bin/rails db
Password for user root: # <--- パスワード（今回はroot）を入力する
psql (12.3)
Type "help" for help.

sample_development=# \l sample*
                                  List of databases
        Name        | Owner | Encoding |  Collate   |   Ctype    | Access privileges
--------------------+-------+----------+------------+------------+-------------------
 sample_development | root  | UTF8     | en_US.utf8 | en_US.utf8 |
 sample_test        | root  | UTF8     | en_US.utf8 | en_US.utf8 |
(2 rows)
sample_development=# \q
```

正しくDBにアクセスし、作成したデータベースの一覧を参照できれば事前準備は完了です。

## `railsコマンド`を触ってみよう

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

- db:xxxx DBのテーブル情報などを更新する
  - db:create
  - db:migrate
  - db:version
- routes ルーティング情報を出力する
- runner ワンライナーや単発のスクリプトなどを実行する

## scaffoldでRailsの開発を体験してみよう

scaffoldとは、rails generateで使用できる、あるテーブルに対してCURD操作を行うWebアプリケーションのソースコード一式を生成するコマンドです。
Railsの仕組みをざっくり確認したい場合や15分でブログを作りたい場合などに利用します。

- ProTip:`./bin/rails generate`ではmodelのみ、controllerのみといったコンポーネント単位でのジェネレートもできます

### scaffoldでファイルを生成する

まずは次のコードを実行してscaffoldを実行します。scaffoldを実行する際はテーブル名に続いてカラムを指定します。`カラム名:DBの型`を指定しますが、DBの型を省略した場合はstring（255文字までの文字列）型となります。

```sh
% ./bin/rails g scaffold blog title
% ./bin/rails g model entry name body:text blog:references
```

この例ではscaffoldで作成したblogに対してリレーションを持つentryというテーブルも作成します。entryは単にテーブルと対応するモデルクラスだけ必要なので`rails g model`としています。

これで必要なファイルが作成できました。この時、DBのテーブル作成などは各DBごとの方言を吸収したDSLで記述したファイルとして、`db/migrate`以下に生成されます。

```sh
% ls -1FA db/migrate
20200802142731_create_blogs.rb
20200802142740_create_entries.rb
```

```ruby
# cat db/migrate/20200802142731_create_blogs.rb
class CreateBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :blogs do |t|
      t.string :title

      t.timestamps
    end
  end
end
```

これらのファイルをマイグレーションファイルと呼びます。
マイグレーションファイルを実際のDBに適用させるためにはrailsコマンドのdb:migrateを使います。

```sh
% ./bin/rails db:migrate
  :
% ./bin/rails db:migrate:status

database: sample_development

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20200802142731  Create blogs
   up     20200802142740  Create entries
```

これでDBの準備ができました。

### scaffoldで生成された機能を画面上で操作する

まず、どのようなURLが生成されているかルーティング情報を確認してみましょう。
出力内容のうち、VerbとURI Patternを見ることでどのようなURLにアクセスすべきかおおよその検討をつけます。

```sh
./bin/rails routes
   Prefix Verb   URI Pattern               Controller#Action
    blogs GET    /blogs(.:format)          blogs#index
          POST   /blogs(.:format)          blogs#create
 new_blog GET    /blogs/new(.:format)      blogs#new
edit_blog GET    /blogs/:id/edit(.:format) blogs#edit
     blog GET    /blogs/:id(.:format)      blogs#show
          PATCH  /blogs/:id(.:format)      blogs#update
          PUT    /blogs/:id(.:format)      blogs#update
          DELETE /blogs/:id(.:format)      blogs#destroy
```

ルーティング情報をイメージしながら、実際にアプリケーションを触ってみます。まずはrails serverを使ってアプリケーションサーバーを起動させます。

```sh
% ./bin/rails s
```

無事に起動したら、まずは http://localhost:3000/blogs へアクセスしましょう。正しくアプリケーションが動いていれば、かっこいいブログ一覧画面が表示されます（初回はデータが一件もないので、「New Blog」のリンクしかありません）。

ここからはしばらく、データの作成や編集、削除などを試してみましょう。この時、デベロッパーツールを表示して、画面遷移時のHTTPメソッドやURLの動きを見ると良いでしょう。

## scaffoldのコードを読んでみよう

TODO