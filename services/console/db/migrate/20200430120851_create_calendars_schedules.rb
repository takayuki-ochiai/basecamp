# frozen_string_literal: true

class CreateCalendarsSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :calendars_schedules do |t|
      t.references  :calendar, foreign_key: true
      t.references  :schedule, foreign_key: true
      t.timestamps
    end

    add_index :calendars_schedules, %i[calendar_id schedule_id], unique: true
    add_index :calendars_schedules, %i[schedule_id calendar_id], unique: true
  end
end
