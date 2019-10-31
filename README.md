# WHAT
@takayuki-ochiai がWebアプリケーションを開発する時に使用する開発環境基盤

# Usage
## 依存ツール、ライブラリ
- Docker
- direnv
- ndenv
- node.js
  - v12.13.0

## インフラ構築
- TODO: ドメイン名の登録だけは事前にやっておく
- TODO: プロジェクト名の置換方法を記載しておく
- iamを構築
- kmsを構築
- ecrを構築
- acmを構築
  - 認証にちょっと時間がかかるので注意
- s3を構築
- networkを構築
- albを構築
  - 依存するリソース
    - network
    - acm
    - s3
- route53を構築
  - 依存するリソース
    - alb
- ecsを構築
  - あらかじめキーペアを作成しておくこと
  - 作成した公開鍵をプロジェクトディレクトリに置いて、パスをpublic_key_path変数にセットすること
  - 依存するリソース
    - iam
    - network
    - s3
    - alb
- rdsを構築
  - 依存するリソース
    - network
    - kms
- elasticacheを構築
  - 依存するリソース
    - network

## Frontend
- デプロイ等の都合上Dockerコンテナで開発しているが、IDEで参照するnode.jsやnode_modulesはホスト側にインストールする必要がある点に注意
  - コンテナ用のnode_modulesとホスト用のnode_modulesの二重管理が必要
  - 新しくパッケージをインストールした時はホスト側で `npm ci && npm cache clean --force` するだけじゃなくて、イメージも作り直す必要がある
- ndenvでNode.js 12.13.0をインストール
- services/frontendに移動して `npm ci && npm cache clean --force`
- プロジェクトのルートディレクトリに戻って `docker-compose up` するとimageのビルドが実行される
- IntelliJ IDEAの自動フォーマットの設定だけ、下記を参考にした
  - https://www.yuts.me/posts/settingEslintOnIdea
  - Prettierプラグインをインストール
  - preferences > Language & Frameworks > JavaScript > Code Quality Tools > ESlint
    - choose manual ESLint Configuration
    - set the ESLint package field to `Detect package and configuration file from the nearest package.json`
    - Configuration file
      - choose automatic search
    - press ok
  - file watcher plugin
    - preferences > Tools > FileWatchers
    - press + at bottom
    - choose Prettier
- 参考記事
  - https://qiita.com/matkatsu8/items/f0a592f713e68a8d95b7

- Firebaseの環境構築
  - GCPで新しくプロジェクトを構築
  - GCPで作ったプロジェクトをもとにFirebaseのプロジェクト作成
  - Firebaseのメニューから開発→Authentication→ログイン方法の設定
  - 承認済みドメインの追加
    - Route53に登録したドメイン名をあらかじめ追加しておく
  - クライアント用のConfigを取得
    - プロジェクトの設定→全般→マイアプリからWebアプリを選択して3つ登録する
      - 開発環境用アプリ
      - ステージング用アプリ
      - 本番用アプリ
    - アプリごとに出力されたAPIKey等をコピーする
      - 公開していい情報ではあるらしいが、念の為gitignoreするファイルに記載しておいた方がいいだろう
      - credentials/client.tsを設定
    - 参考) https://firebase.google.com/docs/web/setup?hl=ja
  - サーバーサイド用のConfigを取得
    - プロジェクトの設定→サービスアカウント→新しい秘密鍵の生成
    - credentials/server.jsonを設定
    - 参考) https://firebase.google.com/docs/admin/setup?hl=ja
    

# Architecture
- 基本的には全てのアプリケーションはコンテナで開発、デプロイする設計

## Application
### Frontend
- 基本はReact.js + TypeScript + Redux
  - Hooksで副作用処理と状態管理が完結できるならReduxは使いたくない
    - Reduxまで覚えさせようとすると学習コストが高くて普及しづらいんだよね…
    - とはいえ、Hooksでどこまでできるか未知数なので、諦めてRedux入れるかもしれないが
- basecamp側では単純なログイン・認証機能のみを持ったSSRも持ったSPAの実装までをサポートするものとする


### Backend
- Frontendが呼び出すbackendのAPIはRuby on Railsを使用する
- 高トラフィックを低コストで処理するというニーズを満たすサーバーはGolangで実装する
  - なんらかの配信機能やログ計測機能のためのサーバーを想定
  - 広告やクーポンなどを配信するウィジェットや、配信結果をログとして出力するサーバーとして利用する

## Middleware
- DBにはMySQL, KVSにはRedisを使用する


## Infrastructure
- 基本的にはAWSを利用する
- AWSの各種サービスはTerraformで管理する
- 本番用とステージング用で同じアカウントを利用するが、別々のリソース、ロールを割り当てる
  - 本来は環境別に別アカウントにした方が安全だが、開発時に必要な品質を担保した上でスピードを重視するためこの構成とする
- Applicationは全てコンテナ化されている前提とし、AWS Fargateにコンテナをデプロイする形式

