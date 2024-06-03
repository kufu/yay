# 現実の複雑さに対応する

「Chapter 4 現実の複雑さに対応する」の補足事項です

## フォームのエラーが表示されない場合

Rails 7 以降では Chapter 3 の補足でも触れた Turbo という機能がデフォルトで有効になっており、フォームの送信などが自動的に非同期で行われます。  
この機能の副作用として、以下のようなコードにおいてブラウザのコンソールに `Form responses must redirect to another location` というエラーが表示され、フォームのエラー表示がうまく更新されない場合があります。

```ruby
def create
  @task = current_user.tasks.new(task_params)
  if @task.save
    redirect_to @task, notice: "タスク「#{@task.name}」を登録しました。"
  else
    render :new
  end
end
```

これは Turbo の機能の一つ Turbo Drive が以下のような仕様であるためです([参考](https://github.com/domchristie/turbo/blob/c458b47c9f4c4bf48ae26f50a3d1bc88ad448039/src/core/drive/form_submission.js#L131-L142))。
- フォーム自体はリダイレクトされることを期待している
- 400番台 または 500番台 のエラーが返却された場合は画面を更新する
  - tips: `render` はデフォルトでステータスコード 200 を返却する
- それ以外の場合はエラー

したがって、以下のように `status` を指定することでエラー表示が正しく更新されるようになります。

```diff
- render :new
+ render :new, status: :unprocessable_entity
```

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
