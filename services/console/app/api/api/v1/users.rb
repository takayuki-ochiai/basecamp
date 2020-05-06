module API
  module V1
    class Users < Grape::API
      #http://localhost:3000/api/v1
      format :json

      #GET /api/v1/users
      resource :users do
        desc 'returns all users'
        get '/' do
          @users = User.all # 最後に評価された値がレスポンスとして返される
        end
      end
    end
  end
end
