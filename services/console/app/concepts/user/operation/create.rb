# frozen_string_literal: true

class User::Operation::Create < Trailblazer::Operation
  step Model(User, :new)
  step Contract::Build(constant: User::Contract::Create)
  step Contract::Validate(key: :user)
  step :persist!

  def persist!(options, **)
    contract = options['contract.default']
    contract.sync

    user = contract.model

    return true if User.find_by(email: user.email)

    ActiveRecord::Base.transaction do
      user.save!
      PrivateCalendar.create!(
        user: user,
        title: 'マイカレンダー'
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    options["result.error"] = e
    false
  end
end
