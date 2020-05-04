class CreateScheduleDates < ActiveRecord::Migration[6.0]
  def change
    create_table :schedule_dates do |t|
      t.date :from, null: false
      t.timestamps
    end
  end
end
