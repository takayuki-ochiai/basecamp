class User < ApplicationRecord
  has_and_belongs_to_many :organizations
  has_many :calendars, dependent: :destroy
  has_many :reference_calendars, dependent: :destroy
  has_many :invitee, as: :invitable, dependent: :destroy
  has_many :reference_calendars, dependent: :destroy
  has_many :attendances, dependent: :destroy
end
