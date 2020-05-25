# frozen_string_literal: true

class ScheduleDatePeriod < ApplicationRecord
  has_one :schedule, as: :schedulable
end
