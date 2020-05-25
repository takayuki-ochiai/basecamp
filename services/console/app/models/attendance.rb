# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :schedules
  belongs_to :user
end
