# 01_ruby

他言語からRubyへ入門する方などへ向けたRubyの基礎知識やRubyならではの特徴などを学習するためのドキュメントです。

## テストの実行方法について

rakeコマンドを通じてテストを実行する設計になっています。

```sh
% bundle install
```

で必要なライブラリをインストールしてから、rakeを実行します。本リポジトリではテストに対して実装が行われていない設計になっているため、テストが大量にfailしますが正しい状態です。

```sh
% bundle exec rake
bundle exec rake
Run options: --seed 64799

# Running:

EEEFEFEEEEEEEEEEEE

Finished in 0.004522s, 3980.5396 runs/s, 442.2822 assertions/s.
    :
    :
Tasks: TOP => default => test
(See full trace by running task with --trace)
```

特定のディレクトリのみテストを実行したい場合はTEST環境変数を利用します。

```sh
% bundle exec rake TEST=test/03_private_symbol/*.rb
```