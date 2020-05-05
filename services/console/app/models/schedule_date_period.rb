class ScheduleDatePeriod < ApplicationRecord
  has_one :schedule, as: :schedulable
end
