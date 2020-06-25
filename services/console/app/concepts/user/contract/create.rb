# frozen_string_literal: true

class User::Contract::Create < Reform::Form
  property :uid
  property :email

  validation do
    params do
      required(:uid).filled(:string)
      required(:email).filled(:string)
    end

    rule(:email) do
      key.failure('has invalid format') unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    end
  end
end
