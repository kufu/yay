# 現実の複雑さに対応する

「Chapter 4 現実の複雑さに対応する」の補足事項です


## 補足

- バリデーションが動くメソッド、動かないメソッドは気にかけてあげてください
    - https://railsguides.jp/active_record_validations.html#バリデーションのスキップ
- `validate`と`validates`に注意
    - `validate`は同じクラス内で定義したバリデーションメソッドやブロック渡しで直接指定する場合に利用します
    - `validates`は別クラスに定義したバリデーションクラスを使ったバリデーションを行います
- beforeコールバック処理で後続の処理を止めたい場合は `throw(:abort)`を使います（そうすると、処理は中断されsaveメソッドなどはfalseを返します）
    - たとえばレコード削除時に状態をチェックしたい場合に `before_destroy` で利用するケースがあります
        - https://railsguides.jp/active_record_callbacks.html#コールバックの停止
        - https://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html

## Rails 6の機能

- Rails 6では複数DBに対応しています
    - db:create:db名などで各処理が行えます
        - 詳しくは1 https://speakerdeck.com/sugamasao/ruby-on-rails-6-dot-0-new-feature?slide=24
        - 詳しくは2 https://railsguides.jp/active_record_multiple_databases.html
