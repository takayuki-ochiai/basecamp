class ScheduleTimePeriod < ApplicationRecord
  belongs_to :schedule, as: :schedulable
end
