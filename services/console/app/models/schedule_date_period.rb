class ScheduleDatePeriod < ApplicationRecord
  belongs_to :schedule, as: :schedulable
end
