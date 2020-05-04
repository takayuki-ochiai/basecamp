class Attendance < ApplicationRecord
  belongs_to :schedules
  belongs_to :user
end
