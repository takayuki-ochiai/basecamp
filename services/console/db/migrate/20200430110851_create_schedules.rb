class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.string     :title,         null: false
      t.references :schedulable,   polymorphic: true, index: true
      t.references :calendar,      foreign_key: true
      t.string     :text
      t.timestamps
    end
  end
end
