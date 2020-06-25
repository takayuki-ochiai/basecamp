class Shared::Representer::Errors < Shared::Representer::Base
  expose :errors do |result|
    result['contract.default'].errors.messages.map do |attr, messages|
      messages.map { |message| "#{attr} #{message}" }
    end.flatten
  end
end

