module API
  class Root < Grape::API
    #http://localhost:3000/api
    prefix 'api'
    format :json

    mount API::V1::Root
  end
end
