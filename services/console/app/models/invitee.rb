# frozen_string_literal: true

class Invitee < ApplicationRecord
  belongs_to :invitable, polymorphic: true
end
