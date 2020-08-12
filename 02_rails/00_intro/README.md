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

- `db:xxxx` DBのテーブル情報などを更新する
  - db:create
  - db:migrate
  - db:version
- `routes` ルーティング情報を出力する
- `runner` ワンライナーや単発のスクリプトなどを実行する

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

- ProTips: generateやconsole、serverといったrailsのコマンドはそれぞれ `g` , `c` , `s` などと省略できます。

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

Statusがupと表示されている行はマイグレーションファイルを適用済みであることを表しています。

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

scaffoldで生成されたかっこいいブログがどのように動いているか、実際のコードをを見てみましょう。

### ルーティングとコントローラー

再掲となりますが、改めてルーティング情報を確認してみましょう。


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

かっこいいブログの一覧画面は `/blogs` でアクセスしたことを思い出してください。ブラウザで`/blogs`へアクセスする場合、通常はHTTPのGETメソッドでアクセスしています。そのことを念頭にroutesの結果を見ると、次の行に対応していることがわかります。

```
Prefix Verb   URI Pattern               Controller#Action
 blogs GET    /blogs(.:format)          blogs#index
```

この行の`Controller#Action`に注目しましょう。ここがURLパターンに対応するコントローラーとメソッドです。
具体的に説明すると、`app/controllers/blogs_controller.rb`にある`index`メソッドが呼ばれるということを表しています。

```ruby
class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  # GET /blogs
  # GET /blogs.json
  def index
    @blogs = Blog.all
  end
  :
end
```

indexメソッドでは、Blogというモデルクラスを通じてblogsテーブルのレコードを全件取得しています。
このデータをビューテンプレートで出力し、HTMLなどをブラウザに返しています。

続いて、URLとコントローラーを紐付けているルーティングの定義を確認してみます。`config/routes.rb`の内容を見てみましょう。

```ruby
Rails.application.routes.draw do
  resources :blogs
end
```

`resources :blogs`と記述されています。これはRailsが提供するCRUD操作の基本的な7アクションを定義するための記法で、resourcesで定義するアクションのうち、特定のアクションだけ使えるようにする、というようなことも可能です。

`resources`という書き方は数ある定義方法の1つです。より詳しくは[Railsガイドのルーティングの章](https://railsguides.jp/routing.html)を参照してください。

ところで、ここまで読んだ方はRailsらしいルーティングって何？と思うかもしれません。そのためのヒントをいくつか例示します。

- RailsはRESTの考え方に基づくURL構造を基本としている
- [DHHはどのようにRailsのコントローラを書くのか](https://postd.cc/how-dhh-organizes-his-rails-controllers/)

より単純に書くと、`get /path/controller`のようなプリミティブなルーティングは定義をせず、`resources`や`resource`を使った定義とshowやonlyを組み合わせた制御でルーティングできないか考えるのが良いでしょう。

### コントローラーからビューへ

ルーティングの定義からアクションまでの流れをここまで解説してきました。
次にアクションからテンプレートを探索する流れを追ってみましょう。

先ほどのindexアクションを再掲します。

```ruby
# app/controllers/blogs_controller.rb
def index
  @blogs = Blog.all
end
```

Railsではこれだけの記述から暗黙的に使用するテンプレートを選択してしまいます。
この例の場合は`app/views/blogs/index.html.erb`を参照します。これは、コントローラー名とアクション名から導かれるものです。

- `app/views/コントローラー名/アクション名.html.erb`

テンプレートファイルの末尾の拡張子はテンプレートエンジンの種別を表していて、`erb`以外に`haml`や`jbuilder`などはよく目にするかもしれません。
また、今回の例で`.html`となっている拡張子部分をRailsではformatと呼んでいます。

formatはhtmlであることをデフォルトとして考えますが、URLに拡張子（`/blogs.html`）をつけたり、ヘッダーで指定するなどすることで、任意のformatをリクエストできます。

indexの動作の場合、ビューテンプレートとして`.html.erb`と`.json.jbuilder`が用意されていることがわかると思います。それぞれのテンプレートを見てみましょう。

```html
# app/views/blogs/index.html.erb の一部抜粋
    <% @blogs.each do |blog| %>
      <tr>
        <td><%= blog.title %></td>
        <td><%= link_to 'Show', blog %></td>
        <td><%= link_to 'Edit', edit_blog_path(blog) %></td>
        <td><%= link_to 'Destroy', blog, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
```

```ruby
# app/views/blogs/index.json.jbuilder
json.array! @blogs, partial: "blogs/blog", as: :blog
```

いずれも`@blogs`を参照していることがわかります。これは、コントローラー内で取得したインスタンス変数をテンプレート内から参照しているということです。
言い換えればテンプレートとコントローラーはインスタンス変数を共有している、とも言えます。そのため、コントローラー内で不必要にインスタンス変数を扱ってしまうとコントローラーで参照しているかもしれないという懸念が生まれ、メンテナンス性に影響を与えます。

### ビューとURL

HTMLを描画する際、リンクやformなど、別URLへ遷移することはよくあります。Railsではアプリケーション内の別Pathへアクセスしやすくするためのヘルパーを用意しています。

先ほどのindex.html.erbを再掲します。

```html
      <tr>
        <td><%= blog.title %></td>
        <td><%= link_to 'Show', blog %></td>
        <td><%= link_to 'Edit', edit_blog_path(blog) %></td>
        <td><%= link_to 'Destroy', blog, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
```

tdタグ内のlink_toに注目してください。link_toはaタグを生成するためのヘルパーメソッドですが、今回は2つ目のlink_toメソッドで第二引数として利用している値`edit_blog_path(blog)`の解説をします。

`edit_blog_path(blog)`は、実際にレンダリングすると`/blogs/1/edit`のようなパスを生成し、blogsコントローラーのeditアクションへのリンクとなります。
この`edit_blog_path`のような記法はパスやURLヘルパーなどと呼ぶもので、ルーティングで定義したPrefixの値を利用しています。`Prefix+_path`とすることでRailsのアクション向けのパスを生成します。この時、ヘルパーの引数にはURI Patternを構築するために必要なパラメーターを渡す必要があります。

```sh
./bin/rails routes
   Prefix Verb   URI Pattern               Controller#Action
    :
edit_blog GET    /blogs/:id/edit(.:format) blogs#edit
```

URLヘルパーを利用する場合、多くはActiveRecordオブジェクトなどを直接引数に渡すことでパスを構築しますが、`edit_blog_path(id: 1)`のようにルーティングに必要なパラメーターを直接渡すことも可能です。

ビューテンプレート向けのヘルパーメソッドはたくさんありますが、URLヘルパーはRailsのルーティングと噛み合わせるための重要なヘルパーなので、忘れないようにしておきましょう。

### モデル

コントローラーで何となく使っていたBlogモデルについて、ソースコードを見てみましょう。

```ruby
# app/models/blog.rb
class Blog < ApplicationRecord
end
```

何もないですね。Blogクラスの親クラスApplicationRecordはActiveRecordクラスを継承した物で、ApplicationRecord自体もほぼ空のクラスです。

```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

`ApplicationRecord`はRailsプロジェクトのモデル全体で設定したい内容などを記述するレイヤーのため、特別な事情が出てくるまでは空のまま扱うことになるでしょう。

そして、これらのコードからわかる通り、scaffold時点でモデルクラスにはアプリケーション固有の実装などはありません。ActiveRecord本体の機能があり、Blogというクラス名とテーブルが紐づいているだけの状態です。

そのため、ここではActiveRecordの基本について解説します。

ActiveRecord、つまりRailsにおけるモデルはデザインパターンのActiveRecordパターンを踏襲した、クエリビルダーとORMを内包したモノです。

ActiveRecordはクエリビルダーのため、次のようなwhereメソッドなどでSQLを発行できます。

```sh
# SQLはイメージです
Blog.all # => SELECT "blogs".* FROM "blogs"
Blog.where(id: 1) #=> SELECT "blogs".* FROM "blogs" WHERE "blogs"."id" = 1
```

モデルについて重要なのは1レコードに相当する単一の要素はActiveRecordのインスタンスで表現されますが、whereの戻り値のような複数レコードにまたがる集合は配列風に扱うことができるActiveRecord::Relationというクラスのインスタンスを返すという点です。

ActiveRecord::Relationはデータの集合を表していますが、このオブジェクト自体はレコードの集合ではありません。ActiveRecordでは実際にActiveRecord::Relationの各要素を必要とするまでSQLの実行を遅延するため、ActiveRecord::Relationオブジェクトを扱う時点ではSQLが発行されません。

この動作は実際のコードを見た方がわかりやすいでしょう。たとえば、メソッドチェーンで条件を重ねる場合や、if文で条件を切り替えるような場合でも、都度SQLを発行するわけではありません。

```ruby
# idとtitleをandでつなげたSQLが組み立てられる
# SELECT "blogs".* FROM "blogs" WHERE "blogs"."id" = 10 AND "blogs"."title" = 'foo'
Blog.where(id: 10).where(title: "foo")

# elseの場合は上の例と同じSQLが組み立てられる
# SELECT "blogs".* FROM "blogs" WHERE "blogs"."id" = 10 AND "blogs"."title" = 'foo'
rel = Blog.where(id: 10)
rel = if cond
        rel.where(title: cond)
      else
        rel.where(title: "foo")
      end
rel
```

なお、どうしてもコードの途中でSQLを実行したいというような場合もあります。そう言ったときは`to_a`メソッドなどを呼ぶと言ったテクニックもあります（カジュアルにやるものではありません）。

また、`find`/`find_by`メソッド、あるいは`ret[0]`のようにActiveRecord::Relationから要素を取得した物はActiveRecordのインスタンスです。このオブジェクトはSQLを発行した後の結果であるため、whereなどクエリビルダーに相当するメソッドは利用できません。

- ProTip
  - 関連先のモデル（アソシエーション）を参照する場合、素朴に参照するとN+1が発生してしまいます
    - その場合、SQLレベルでjoinするか、あらかじめ関連先を読み込んでおく必要があります
      - `preload`/`joins`/`includes`/`eager_loads`/`left_joins`あたりをうまく使ってください。複数の関連先を読み込んだり、関連先の関連先を読み込むようにすることもできるので、どのような違いがあるか色々試すと良いでしょう
  - ActiveRecordオブジェクトは重い
    - ActiveRecordは非常に高機能ですが、一方、非常に重いオブジェクトでもあります。そのため、取得するレコードが多い場合はオブジェクトの生成を抑える方法を検討すると良いでしょう。
      - たとえば、単にidの配列が欲しい場合は`select(:id)`ではなく`pluck(:id)`を使う
      - たとえば、whereで数千件取得するのではなく`find_each`を使いある程度の要素単位で扱う

## scaffoldのコードを編集してみよう

to be continued...