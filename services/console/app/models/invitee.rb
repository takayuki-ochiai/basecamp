class Invitee < ApplicationRecord
  belongs_to :invitable, polymorphic: true
end
