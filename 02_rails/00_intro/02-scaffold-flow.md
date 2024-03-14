# scaffoldでRailsの開発を体験してみよう

scaffoldとは、rails generateで使用できる、あるテーブルに対してCRUD操作を行うWebアプリケーションのソースコード一式を生成するコマンドです。
Railsの仕組みをざっくり確認したい場合や15分でブログを作りたい場合などに利用します。

- ProTip:`./bin/rails generate`ではmodelのみ、controllerのみといったコンポーネント単位でのジェネレートもできます

## scaffoldでファイルを生成する

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

## scaffoldで生成された機能を画面上で操作する

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
