# Railsツアー

`rails`コマンドや`scaffold`で生成されたコードを眺めて、Railsの世界観を身につけ用の時間です

## 事前準備

地味に時間が掛かるので、以下を参考に`rails new`まで済ませておいて欲しいです。

本リポジトリのトップページにあるREADMEを参考にRuby 2.7系やRails 6.0系、そしてnodeなどのインストールを行っておいてください。

### サンプルアプリケーションの作成

コマンドの詳しい意味などは本編で解説するので、まずは以下のコマンドを実行してRailsアプリケーションを作成します。

`sample` 部分はアプリケーション名なので、愛着のわくアプリケーション名をつけてください。

```sh
% rails new sample --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable
```

このコマンドでRailsアプリケーションの作成やyarnの実行などまで進められれば準備完了です。
