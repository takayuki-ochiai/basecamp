# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances do |t|
      t.references :user,     foreign_key: true
      t.references :schedule, foreign_key: true
      t.integer    :status,   null: false
      t.timestamps
    end
  end
end
