class ScheduleTimePeriod < ApplicationRecord
  has_one :schedule, as: :schedulable
end
