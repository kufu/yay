# scaffoldのコードを読んでみよう

scaffoldで生成されたかっこいいブログがどのように動いているか、実際のコードをを見てみましょう。

## 大まかなディレクトリ構成

コードを解説を始める前に簡単なディレクトリ構成について解説します。
もっとも重要なディレクトリは`app`です。appディレクトリ内にはRailsの基本構成、MVCに対応するmodels、viewes、controllersがあります。

```sh
% ls -1FA app
assets/
controllers/
helpers/
javascript/
jobs/
models/
views/
```

そして、コントローラーとビューは命名規則によって暗黙的に関連付けされます。

```sh
 % ls -1FA app/controllers
application_controller.rb
blogs_controller.rb
concerns/
```

たとえば、blogs_controller.rbの場合。ビューでは`views/blogs`ディレクトリ内のテンプレートを参照するという形です。

```sh
% ls -1FA app/views/blogs
_blog.json.jbuilder
_entry.html.erb
_form.html.erb
edit.html.erb
index.html.erb
index.json.jbuilder
new.html.erb
show.html.erb
show.json.jbuilder
```

モデルの場合はファイル名によって他のレイヤーと連動はしませんが、モデル名（単数形）とDB上のテーブル名（複数形）という関連があります。

```sh
% ls -1FA app/models
application_record.rb
blog.rb
concerns/
entry.rb
```

他には、設定ファイルに関する内容を保存する`config`やDBに関する定義ファイルなどを保存する`db`ディレクトリなどがあります。

詳しくは都度解説していくので、まずはこんな感じの構成があるということを頭に入れておいてください。

## ルーティングとコントローラー

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

indexメソッドでは、Blogというモデルクラスを通じてblogsテーブルのレコードを全件取得しています。
このデータをビューテンプレートで出力し、HTMLなどをブラウザに返しています。

続いて、URLとコントローラーを紐付けているルーティングの定義を確認してみます。`config/routes.rb`の内容を見てみましょう。

```ruby
Rails.application.routes.draw do
  resources :blogs
end
```

`resources :blogs`と記述されています。これはRailsが提供するCRUD操作の基本的な7アクションを定義するための記法で、resourcesで定義するアクションのうち、特定のアクションだけ使えるようにする、というようなことも可能です。

`resources`という書き方は数ある定義方法の1つです。より詳しくは[Railsガイドのルーティングの章](https://railsguides.jp/routing.html)を参照してください。

ところで、ここまで読んだ方はRailsらしいルーティングって何？　と思うかもしれません。そのためのヒントをいくつか例示します。

- RailsはRESTの考え方に基づくURL構造を基本としている
- [DHHはどのようにRailsのコントローラを書くのか](https://postd.cc/how-dhh-organizes-his-rails-controllers/)

より単純に書くと、`get /path/controller`のようなプリミティブなルーティングは定義をせず、`resources`や`resource`を使った定義とshowやonlyを組み合わせた制御でルーティングできないか考えるのが良いでしょう。

## コントローラーからビューへ

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

いずれも`@blogs`を参照していることがわかります。これは、コントローラー内で取得したインスタンス変数をテンプレート内から参照しているということです。なお、参照できるのは `@` で始まるインスタンス変数のみであり、メソッド内のローカル変数を共有することはできません。
言い換えればテンプレートとコントローラーはインスタンス変数を共有している、とも言えます。そのため、コントローラー内で不必要にインスタンス変数を扱ってしまうとコントローラーで参照しているかもしれないという懸念が生まれ、メンテナンス性に影響を与えます。

- ProTip:今回のJSONの例では `partial: "blogs/blog"` を使ってblogオブジェクトの中でどの要素を返却するか明示しています
  - こういう対応をせず、カラムにある情報をすべて出すような実装をしてしまうと、本来表に出してはいけない情報を出力してしまう場合があるので、気をつけましょう（たとえば`Blog.all.to_json`で全てのデータをフィルターせず返してしまうような実装は要注意）
  - 事例と思われるもの：userごとのハッシュ化したパスワードとsaltが漏れてしまった例
    - https://jiraffe.co.jp/news/2019/01/31/1321/
    - https://jiraffe.co.jp/news/2019/02/22/1352/
  - 対策の参考文献：http://joker1007.hatenablog.com/entry/2020/08/17/141621

`partial: "blogs/blog"` でblogオブジェクトの要素をフィルタリングしている例

```ruby
# app/views/blogs/_blog.json.jbuilder
json.extract! blog, :id, :title, :created_at, :updated_at
json.url blog_url(blog, format: :json)
```


ここまではindexアクションを元にした暗黙的なテンプレートの選択について流れをみてきました。
しかし、実際のアプリケーションではHTMLとJSONで同じデータ形式を返すだけでは終わらない場合もあります。
そういったformat単位でコントローラー内の処理を変えたい場合はrespond_toを使います。
たとえば、updateアクションなどはformatによってレスポンスを変更しています。また、respond_toとセットである必要はありませんが、renderメソッドを使うことで任意のテンプレートを指定するようなことが可能です。

```ruby
def update
  respond_to do |format|
    if @blog.update(blog_params)
      format.html { redirect_to @blog, notice: 'Blog was successfully updated.' }
      format.json { render :show, status: :ok, location: @blog }
    else
      format.html { render :edit }
      format.json { render json: @blog.errors, status: :unprocessable_entity }
    end
  end
end
```

## ビューとURL

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

また、`_path`ではなく`_url`を末尾に追加するヘルパーもあります。`_url`の場合はパス情報だけではなく、httpから始まる完全なURLを返します。

```ruby
# rails cでは`app`経由でpathやurlヘルパーを使うことができます
irb(main):004:0> app.edit_blog_path(blog)
=> "/blogs/1/edit"
irb(main):005:0> app.edit_blog_url(blog)
=> "http://www.example.com/blogs/1/edit"
```

ビューテンプレート向けのヘルパーメソッドはたくさんありますが、URLヘルパーはRailsのルーティングと噛み合わせるための重要なヘルパーなので、忘れないようにしておきましょう。

## フォームとルーティング

ここまでコントローラーからビューへの流れを解説していきましたが、逆にビューからコントローラーへの流れについてもう少し詳しく解説します。
単にaタグでのリンクの場合は指定したパスへGETアクセスするだけですが、データを更新する場合は少し込み入っています。

今回はupdateの例を見てみましょう。updateアクションへ到達するためにはeditアクションで編集画面を表示し、編集画面からformを使ってupdateアクションへアクセスしています。

まずはeditのテンプレートを見てみましょう。

```ruby
# app/views/blogs/edit.html.erb
<h1>Editing Blog</h1>

<%= render 'form', blog: @blog %>

<%= link_to 'Show', @blog %> |
<%= link_to 'Back', blogs_path %>
```

edit.html.erbの中にformタグは見当たりませんね。formタグは共通の部品として切り出しているため、別ファイルを呼び出す形になっています。このような部品単位のテンプレートを部分テンプレートやパーシャルと呼びます。

実際のコードとしては`<%= render 'form', blog: @blog %>`がパーシャルで呼び出している部分です。この場合、`form`というパーシャルを指定していますが、ファイル名の探索としては`_form`を探索します。パーシャルとして利用するテンプレートファイルはファイル名の先頭に`_`を付与させることを覚えておきましょう。

それではformタグの実態を見てみましょう。

```ruby
<%= form_with(model: blog, local: true) do |form| %>
  <% if blog.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(blog.errors.count, "error") %> prohibited this blog from being saved:</h2>

      <ul>
        <% blog.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Railsではform_withというヘルパーを使ってformタグを生成させます。form_withを使うことでmodelオブジェクトの状態からリクエスト先などを生成しています。

さて、ここでルーティング情報を改めてみましょう。`blogs#update`の行に注目してください。

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

blogs#updateはPATCHやPUTメソッドでリクエストを送ると定義されています。
しかし、世の中のブラウザの実装としてPATCHメソッドなどを正しく実装されているとは限りません。そのため、RailsではformタグとしてはPOSTで送信しつつ、hiddenパラメーターでPATCHやPUTを使っているということを明示しています。

![編集画面で生成されたformタグ](./images/form.png)

このような工夫をしてREST的なHTTPの動きと現実の齟齬を吸収しています。
通常アプリケーションを開発しているときはform_withヘルパーを使うことでこういった点については気にせず実装できます。

## モデル

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