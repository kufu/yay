# scaffoldのコードを編集してみよう

ここからはscaffoldで生成されたコードを編集して、少しコードを書いてみましょう。
編集するコード例は[サンプルリポジトリ](https://github.com/sugamasao/basic_rails_sample_code/commits/master)に置いてあるので、最終形をみたい方はそちらをみてください。

今回のRailsツアーで作成したサンプルアプリケーションでは、scaffoldで作成したモデルの他にentryというモデルを作成したことを覚えているでしょうか？

scaffoldで作成しただけでは別モデルとの関連付けは行われていないので、その関連づけを元にRailsアプリケーションを拡張してみましょう。

## モデルの関連付け

Railsではモデル同士の関連付けを実現させるため、`has_many`や`has_one`、`belongs_to`メソッドを使います。

今回の例ではBlogモデルからEntryモデルへ1対多を表現するため、Blogモデル側にhas_manyを指定します。

```ruby
# app/models/blog.rb
class Blog < ApplicationRecord
  # dependent: :destroyをつけると、blog削除時に関連するレコード(entry)も一緒に削除します
  has_many :entries, dependent: :destroy
end
```

こうすると、Blogモデルに関連するentryをentriesという名称で参照できます。

```ruby
Blog.first.entries.each do |entry|
  :
end
```

ここでは1対多の関連を記述しましたが、それ以外に多対多など柔軟に設定する方法があります。より詳しくはRailsガイドの[Active Record の関連付け](https://railsguides.jp/association_basics.html)を参照してください。

この関連を活用して、db/seeds.rbに初期データの投入処理を書いてみましょう。

```ruby
# db/seeds.rb
5.times do |n|
  b = Blog.create(title: "blog #{n}")
  Random.rand(1..4).times do |_n|
  # blogの関連として作成したEntryを追加する
    b.entries << Entry.create(name: "entry #{_n}", body: "あ" * _n)
  end
end
```

seeds.rbに追加したら、`db:seed`を使ってデータを投入してみます。

```sh
% ./bin/rails db:seed
```

とくにエラー出なければ成功です。データを確認してみましょう。

```ruby
irb(main):001:0> Blog.last.entries.count
   (0.7ms)  SELECT sqlite_version(*)
  Blog Load (0.2ms)  SELECT "blogs".* FROM "blogs" ORDER BY "blogs"."id" DESC LIMIT ?  [["LIMIT", 1]]
   (0.2ms)  SELECT COUNT(*) FROM "entries" WHERE "entries"."blog_id" = ?  [["blog_id", 5]]
=> 2
irb(main):002:0> Blog.last.entries
  Blog Load (0.2ms)  SELECT "blogs".* FROM "blogs" ORDER BY "blogs"."id" DESC LIMIT ?  [["LIMIT", 1]]
  Entry Load (0.3ms)  SELECT "entries".* FROM "entries" WHERE "entries"."blog_id" = ? LIMIT ?  [["blog_id", 5], ["LIMIT", 11]]
=> #<ActiveRecord::Associations::CollectionProxy [#<Entry id: 9, name: "entry 0", body: "", blog_id: 5, created_at: "2020-08-16 05:56:36", updated_at: "2020-08-16 05:56:36">, #<Entry id: 10, name: "entry 1", body: "あ", blog_id: 5, created_at: "2020-08-16 05:56:36", updated_at: "2020-08-16 05:56:36">]>
```

## ビューの拡張

blogからentryを参照できるようにしたので、ビューでも表示できるようにしてみましょう。

今回は素朴にindexページにentry要素も表示できるようにしてみます。

https://github.com/sugamasao/basic_rails_sample_code/commit/0378697801fe5b7639726faa1a1b9e0abcd49414

```html
# app/views/blogs/index.html.erb
     <% @blogs.each do |blog| %>
       <tr>
         <td><%= blog.title %></td>
+        <td>
+          <ul>
+            <% blog.entries.each do |entry|%>
+              <li><%= entry.name %> | <%= entry.body %></li>
+            <% end %>
+          </ul>
+        </td>
         <td><%= link_to 'Show', blog %></td>
         <td><%= link_to 'Edit', edit_blog_path(blog) %></td>
         <td><%= link_to 'Destroy', blog, method: :delete, data: { confirm: 'Are you sure?' } %></td>
```

見た目の美しさはともかく、blogに紐づくentryを表示することができるようになりました。
今回の例はかなり単純な構造ですが、多くの場合は関連先の情報を出力する部分を別テンプレートに切り出すと見通しが良くなります。

パーシャルの機能を使って切り出してみましょう。
まずはファイルを新しく作成し、entryの内容を出力している部分を移します。

```ruby
# app/views/blogs/_entry.html.erb
<li><%= entry.name %> | <%= entry.body %></li>
```

次に、元のindex.html.erbから`_entry.html.erb`を読み込むようにします。
renderメソッドのポイントは`partial: テンプレート名`の指定と、localsです。
単純にテンプレートを読み込むだけなら`partial:`を指定せずテンプレート名を指定するだけで動作しますが、`locals`など部分テンプレート向けの機能を有効にするためには`partial:`によるテンプレート名の指定が必要です。

また、`locals`を使うことで、読み込むテンプレート内で使用する変数名を明示します。
`{ entry: entry }`とした場合は`{ _entry.html.erb内で利用する変数名: index.html.erb内で使用している変数名 }`ということを表しています。

- ProTip:インスタンス変数であればlocalsを経由せずに参照できてしまいますが、扱う変数スコープを狭めるためにもlocalsを経由した変数の受け渡しをするようにしましょう

```html
         <td>
           <ul>
             <% blog.entries.each do |entry|%>
-              <li><%= entry.name %> | <%= entry.body %></li>
+              <%= render partial: "entry", locals: { entry: entry } %>
             <% end %>
           </ul>
         </td>
```

単純に部分テンプレートを使う場合はここまでの記述で十分なのですが、今回の例のようにループして何回もテンプレートを描画する場合、この実装では都度テンプレートファイルを読み込んでしまい描画に時間がかかってしまいます。

このような問題を解決するため、partialで描画する場合collectionというオプションを利用できます。collectionを使って描画すると次のようになります。

```html
         <td><%= blog.title %></td>
         <td>
           <ul>
-            <% blog.entries.each do |entry|%>
-              <%= render partial: "entry", locals: { entry: entry } %>
-            <% end %>
+            <%= render partial: "entry", collection: blog.entries, as: :entry %>
           </ul>
         </td>
         <td><%= link_to 'Show', blog %></td>
```

このcollectionの有無でどのような違いがあるか、実際にアプリケーションを動かしてRailsのログの出力結果を見比べてみると良いでしょう。

## コントローラーと例外処理

コントローラーでの処理では例外をキャッチして任意のレスポンスを返す場合があります。
個別のロジックに対応する例外処理が必要な場合もありますが、一方で、認証の失敗などアプリケーション全体で同じように取り扱いたい例外もあります。

Railsではいくつかの例外は自動的にハンドリングするものがあります。たとえば、ActiveRecord::RecordNotFoundが発生した場合は500エラーにならず404のステータスコードを返します。

一律で例外に対応したい場合は各コントローラーの親クラスとして定義されているApplicationControllerでrescue_fromを使います。

次の例はActiveRecord::RecordNotFoundが発生した時に明示的にレスポンスを変更する例です。

https://github.com/sugamasao/basic_rails_sample_code/commit/c073375bdf79299a32bdf688fa9f4ac02d46632b

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
```

この例のようにrescue_fromメソッドに対して捕捉したい例外クラスと、その時に実行するメソッドを記述します。

https://railsguides.jp/action_controller_overview.html#rescue

## もう少し詳しいモデルの説明

ここまではモデルに対して関連付けしか行なっていませんでしたが、もう少し詳しい使い方をみていきましょう。

### バリデーション

ActiveRecordでは、アプリケーションで取り扱うバリデーションを記述する仕組みがあります。

たとえば、Blogのタイトルは空欄を許さず、かつユニークである用件があるとしましょう。その場合、次のようにvalidatesメソッドを使って定義できます。

https://github.com/sugamasao/basic_rails_sample_code/commit/7187baf4f48c4cb5137176a273170cdc9f3dcd62

```ruby
class Blog < ApplicationRecord
  has_many :entries, dependent: :destroy
  validates :title, presence: true
  validates :title, uniqueness: true
end
```

presenceやuniqunessといった指定はRailsが標準で提供しているものですが、より複雑な定義の場合は独自に定義することも可能です。

どのような定義があるかはRailsガイドの[バリデーションについて](https://railsguides.jp/active_record_validations.html)を参照すると良いでしょう。

また、バリデーションは柔軟に設定できる機能ですが、not nullやuniq indexのようなDBの制約も忘れずに設定しましょう。二度手間のように感じるかもしれませんが、アプリケーション上のuniqunessなチェックなどはリクエストのタイミングによってはすり抜けてしまう可能性があるためです。

### スコープ

ActiveRecordではwhere区などのクエリを部品として扱いやすくするためのscopeという機能を提供しています。

https://github.com/sugamasao/basic_rails_sample_code/commit/1deb6f677b92e228b5411e021845a97f39128ad7

```ruby
class Blog < ApplicationRecord
  has_many :entries, dependent: :destroy
  validates :title, presence: true
  validates :title, uniqueness: true
  scope :title_search, -> (title) { where('title like :title', title: "%#{title}%") }

  # return by "all"
  scope :notfound_scope, -> { where(title: "100000").first }

  # return by nil
  def self.notfound_method
    where(title: "100000").first
  end
end
```

scopeを使うことで検索条件に名前をつけることができます。title_searchというscopeを定義した場合は次のように呼び出すことができます。

```ruby
Blog.title_search('foo')
```

scopeはモデルに対してクラスメソッドを定義した場合と非常に良く似ています。`notfound_scope`と`notfound_method`は一見同じように見えると思います。
しかし、大きな違いが一点あります。scopeの場合、戻り値がnilになった場合その条件を無かったことにします。一方、クラスメソッドで定義した場合はnilの場合でもそのままnilを返します。

次はscopeを呼び出した場合の動きです。対象となるレコードが存在すればActiveRecord::Relationを返しますが、存在しない場合はそのscopeの条件を外したSQLを発行していることがわかります。

```ruby
irb(main):001:0> Blog.notfound_scope
   (1.9ms)  SELECT sqlite_version(*)
  Blog Load (0.8ms)  SELECT "blogs".* FROM "blogs" WHERE "blogs"."title" = ? ORDER BY "blogs"."id" ASC LIMIT ?  [["title", "100000"], ["LIMIT", 1]]
  Blog Load (0.3ms)  SELECT "blogs".* FROM "blogs" LIMIT ?  [["LIMIT", 11]]
```

一方、クラスメソッドの場合はどちらの場合でもそのまま実行します。

```ruby
irb(main):012:0> Blog.notfound_method
  Blog Load (0.1ms)  SELECT "blogs".* FROM "blogs" WHERE "blogs"."title" = ? ORDER BY "blogs"."id" ASC LIMIT ?  [["title", "100000"], ["LIMIT", 1]]
```

scopeはメソッドチェーンでうまく物事を解決できるようにActiveRecord::Relationを返すように工夫されているため、この動作の違いは把握しておくと良いでしょう。

また、scoepの一種としてdefault_scopeという機能もあります。default_scopeはscopeを明示せずとも自動的に付与されるscopeのことです。たとえば論理削除したデータをdefault_scopeで非表示にするような考え方は、一見、良い方法に思えます。しかし、別の軸から検索する場合は常にunscopedでscopeを外す処理を追加しないといけなかったり、意図せずdefault_scopeの条件が付与されてしまい時間を溶かしてしまう、というようなケースもあるため、使う場合は慎重に扱いましょう。

より詳しい解説はRailsガイドの[スコープに関する解説](https://railsguides.jp/active_record_querying.html#%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%97)を参考にしてください。
