# テストをはじめよう

「Chapter 5 テストをはじめよう」の補足事項です。

## 補足

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
