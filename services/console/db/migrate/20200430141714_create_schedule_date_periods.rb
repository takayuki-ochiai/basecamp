# frozen_string_literal: true

class CreateScheduleDatePeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :schedule_date_periods do |t|
      t.date :from, null: false
      t.date :to,   null: false
      t.timestamps
    end
  end
end
