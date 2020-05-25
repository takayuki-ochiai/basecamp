# frozen_string_literal: true

class ScheduleDate < ApplicationRecord
  has_one :schedule, as: :schedulable
end
