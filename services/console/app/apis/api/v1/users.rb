module API
  module V1
    class Users < Grape::API
      format :json

      resource :users do
        desc 'returns all users'
        get '/' do
          @users = User.all # 最後に評価された値がレスポンスとして返される
        end

        params do
          requires :uid, type: String, desc: 'Firebase uid.'
        end
        route_param :uid do
          # POST /api/v1/users/:uid/initial_data
          desc 'setup user initial data.'
          params do
            requires :email, type: String
          end
          post '/initial_data' do
            status 200
            begin
              user_params = ActionController::Parameters.new(params).permit(:uid, :email)
              return { res: 'success' } if User.find_by(uid: user_params[:uid])
              ActiveRecord::Base.transaction do
                new_user = User.create!(user_params)
                PrivateCalendar.create!(
                  user: new_user,
                  title: 'マイカレンダー'
                )
              end
            rescue ActiveRecord::RecordInvalid
              error!("Create Initial Data Failed /api/v1/users/:uid/initial_data", status=400, headers=nil)
            end
            { res: 'success' }
          end
        end
      end
    end
  end
end
