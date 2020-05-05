class ScheduleDate < ApplicationRecord
  has_one :schedule, as: :schedulable
end
