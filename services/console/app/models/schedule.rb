class Schedule < ApplicationRecord
  has_and_belongs_to_many :calendars
  has_many :invitees, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_one :schedulable, polymorphic: true, dependent: :destroy
end