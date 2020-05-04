class Schedule < ApplicationRecord
  belongs_to :calendar
  has_many :invitees, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_one :schedulable, polymorphic: true, dependent: :destroy
end