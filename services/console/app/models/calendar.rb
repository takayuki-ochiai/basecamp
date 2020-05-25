# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :schedules, dependent: :destroy
end
