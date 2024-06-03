# テストをはじめよう

「Chapter 5 テストをはじめよう」の補足事項です。

## Turbo 環境においてテストが不安定な場合

Rails 7 では Turbo がデフォルトで有効となっており、非同期にフォームの処理を行う関係で以下のようなログイン周りのテストの実行が不安定になる（スクリーンショットを確認すると、ログイン画面から遷移されずに止まった状態になっている など）傾向があります。

```ruby
before do
  visit login_path
  fill_in 'メールアドレス', with: login_user.email
  fill_in 'パスワード', with: login_user.password
  click_button 'ログイン'
end
```

この場合、ログインボタンにIDを付与し、画面遷移によってログインボタンが非表示になるまで待機してから次の処理に進むことで解決する場合があります。

```diff
- <%= f.submit 'ログイン', class: 'btn btn-primary' %>
+ <%= f.submit 'ログイン', class: 'btn btn-primary', id: "login-button" %>
```

```diff
  before do
    visit login_path
    fill_in 'メールアドレス', with: login_user.email
    fill_in 'パスワード', with: login_user.password
    click_button 'ログイン'
+   expect(page).not_to have_selector "#login-button"
  end
```

## 補足

### 表示形式を変える

デフォルトでは `...` のような形で実行結果が表示されますが、`--format documentation` ( 省略形: `-f d` ) を指定すると書籍に記載されているような形式で出力できます。

```
$ bundle exec rspec spec/system/tasks_spec.rb
.....

Finished in 7.14 seconds (files took 4.85 seconds to load)
5 examples, 0 failures
```

```
$ bundle exec rspec spec/system/tasks_spec.rb -f d

タスク管理機能
  一覧表示機能
    ユーザーAがログインしているとき
      behaves like ユーザーAが作成したタスクが表示される
        is expected to have text "最初のタスク"
(省略)

Finished in 4.38 seconds (files took 1.91 seconds to load)
5 examples, 0 failures
```

### 一部のテストケースのみ実行する

spec ファイル全体でなく、一部のテストケースのみ実行したい場合は以下のように指定できます。

```shell
$ bundle exec rspec <specファイル>:<行数>
```

例えば以下のようなファイルがある場合

`spec/models/user_spec.rb`
```
01: describe User, type: :model do
02:   describe '.active' do # <= このテストケースのみ実行したい
03:     it 'returns active users' do
04:       expect(User.active).to eq [user1, user2, user4]
05:     end
06:   end
07:
08:   describe '.inactive' do
09:     it 'returns inactive users' do
10:       expect(User.inactive).to eq [user3]
11:     end
12:   end
13: end
```

特定のテストケース（ `.active` ）のみ実行したいときは以下のように指定します。

```shell
$ bundle exec rspec spec/models/user_spec.rb:2
```

複数の行を指定することもできます。

```shell
$ bundle exec rspec spec/models/user_spec.rb:2:8
```

### spec の構造を確認する

以下のようにオプションを指定すると、spec を実際に動かすことなく spec の構造を確認できます。

```shell
$ bundle exec rspec -f d --dry-run --order defined spec/models/user_spec.rb

User
  .active
    returns active users
  .inactive
    returns inactive users
```
