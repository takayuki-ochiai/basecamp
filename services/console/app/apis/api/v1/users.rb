# frozen_string_literal: true

module API
  module V1
    class Users < Grape::API
      format :json

      resource :users do
        desc 'returns all users'
        get '/' do
          @users = User.all # 最後に評価された値がレスポンスとして返される
        end

        # POST /api/v1/users
        desc 'create user and default calendar'
        post '/' do
          result = User::Operation::Create.call(params: params)
          if result.success?
            present result, with: User::Representer::Create
          else
            present result, with: Shared::Representer::Errors
          end
        end
      end
    end
  end
end
