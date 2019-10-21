# WHAT
@takayuki-ochiai がWebアプリケーションを開発する時に使用する開発環境基盤

# Usage
## 依存ツール、ライブラリ
- Docker
- direnv

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
- 本番用とステージング用で同じアカウントを利用するが、別々のリソース、ロールを割り当てる
  - 本来は環境別に別アカウントにした方が安全だが、開発時に必要な品質を担保した上でスピードを重視するためこの構成とする
- Applicationは全てコンテナ化されている前提とし、AWS Fargateにコンテナをデプロイする形式

