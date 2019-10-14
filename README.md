# WHAT
@takayuki-ochiai がWebアプリケーションを開発する時に使用する開発環境基盤


# Architecture
- 基本的には全てのアプリケーションはコンテナで開発、デプロイする設計

## Application
### Frontend
- 基本はReact.js + TypeScript + Redux
  - Hooksで副作用処理と状態管理が完結できるならReduxは使いたくない
    - Reduxまで覚えさせようとすると学習コストが高くて普及しづらいんだよね…
    - とはいえ、Hooksでどこまでできるか未知数なので、諦めてRedux入れるかもしれないが
- SSRはbasecamp側では考慮していない。必要に応じてforkしたプロジェクトでNext.jsなどを使うこと
  - Next.jsはあんまりいい評判を聞かないのでbasecampではサポートしないことにした
- basecamp側では単純なログイン・認証機能のみを持ったSPAの実装までをサポートするものとする


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
- Applicationは全てコンテナ化されているため、AWS Fargateにコンテナをデプロイする形式

