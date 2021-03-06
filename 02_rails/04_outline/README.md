# Railsの全体像を理解する

「Chapter 6 Railsの全体像を理解する」の補足事項です。

というつもりだったのですが、あまりコレという補足事項はありません。

## フロントエンドについて

Rails 5.2まではSprocetsを使ってJSのビルド・コンパイルを行っていましたが、Rails 6.0からJSはWebpackerを、CSSは引き続きSprocketsを使う体制になっています。

Webpackerはwebpackの薄いラッパーですが、Webpackerを使うといままでのSprocekts時代と同じ要領でビルドや配信、CSRF対策などができるのでWebpackerをそのまま使うかwebpackに切り替えるかはフロントエンドの習熟度や重要度に応じて検討すると良いでしょう。

## `rails c` 便利Tips

rails cで立ち上げたセッションでは、デバッグ用のオブジェクト（メソッド）がいくつか生成されます。
よく利用されるものを抜粋しますが、詳しくは次のURLを参照してください。

- https://api.rubyonrails.org/classes/Rails/ConsoleMethods.html
- https://signalvnoise.com/posts/3176-three-quick-rails-console-tips

- app
- helper
- reload!（rails c内のRailsの環境をリロードします）

appを使うと、URLヘルパーの動作を確認したり、リクエスト・レスポンスを確認したりできます。

```ruby
irb(main):001:0> app.blogs_url
=> "http://www.example.com/blogs"
irb(main):002:0> app.get 'http://localhost:3000/blogs'
Started GET "/blogs" for 127.0.0.1 at 2020-10-10 17:31:20 +0900
  :
Completed 200 OK in 103ms (Views: 81.6ms | ActiveRecord: 5.3ms | Allocations: 24689)
=> 200
irb(main):007:0> app.response.status
200
=> nil
```

helperオブジェクトを使うと、ヘルパーメソッドの動きを確認できます。画面のリロードよりはトライアンドエラーしやすいので便利です。

```ruby
irb(main):011:0> helper.link_to 'blog link', app.blogs_url
=> "<a href=\"http://localhost:3000/blogs\">blog link</a>"
```

## Credentialsの機能について

Rails 5.2で新しく導入された秘密情報の管理方法`credentials`ですが、Rails 6.0ではより改良されています。
Rails 5.2では本番環境用の管理という面が強かったのですが、さすがにそれはストロングスタイルすぎたということでRails 6.0ではstaging用などの環境ごとに値を設定できる仕組みが導入されました。

- https://github.com/rails/rails/pull/33521
