class Shared::Representer::Base < Grape::Entity
  expose :ok do |result|
    result.success?
  end
end
