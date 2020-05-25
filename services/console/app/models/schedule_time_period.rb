# frozen_string_literal: true

class ScheduleTimePeriod < ApplicationRecord
  has_one :schedule, as: :schedulable
end
