class CreateScheduleTimePeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :schedule_time_periods do |t|
      t.datetime :from, null: false
      t.datetime :to,   null: false
      t.timestamps
    end
  end
end
