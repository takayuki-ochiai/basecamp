class ScheduleDate < ApplicationRecord
  belongs_to :schedule, as: :schedulable
end
