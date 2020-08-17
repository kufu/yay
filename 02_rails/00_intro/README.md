# Railsツアー

`rails`コマンドや`scaffold`で生成されたコードを眺めて、Railsの世界観を身につけようの時間です

## 事前準備

本リポジトリの[トップページにあるREADME](../../README.md)を参考にRuby 2.7系やRails 6.0系、そしてnodeなどのインストールを行っておいてください。

### サンプルアプリケーションの作成

コマンドの詳しい意味などは本編で解説するので、まずは以下のコマンドを実行してRailsアプリケーションを作成します。

`sample` 部分はアプリケーション名です。

```sh
% rails new sample --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable -d postgresql
% cd sample
```

そして、このドキュメントと同じ階層にある[docker-compose.yml](./docker-compose.yml)を上記のアプリケーションと同じ階層（この場合はsampleディレクトリの中）にコピーし、`docker-compose up`を実行してDocker上にDBを立ち上げます。

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

## コンテンツ

1. [`railsコマンド`を触ってみよう](./01-rails-command.md)
2. [scaffoldでRailsの開発を体験してみよう](./02-scaffold-flow.md)
3. [scaffoldのコードを読んでみよう](./03-scaffold-read.md)
4. [scaffoldのコードを編集してみよう](./04-scaffold-write.md)
