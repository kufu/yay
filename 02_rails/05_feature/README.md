# 機能を追加してみよう

「Chapter 7 機能を追加してみよう」の補足事項です。

## 補足: `render` や `redirect_to` の後も処理は続く

アクション内で `render` や `redirect_to` を実行し、そこで処理を中断させたい場合は必ず `return` しましょう。
`return` しない場合、その後の処理が引き続き実行されて意図せぬ結果になることがあります。

参考: https://railsguides.jp/layouts_and_rendering.html#redirect-to%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%99%E3%82%8B


```ruby
def create
  if error
    redirect_to error_path
    return
    # return しない場合はこの後も処理が続く
  end

  if another_error
    redirect_to error_path and return
    # and return というイディオムが使われることもあります
    # && return では意図したとおりに動かないので注意
  end

  if @user.save!
    redirect_to @user
  else
    render :new
  end
end
```
