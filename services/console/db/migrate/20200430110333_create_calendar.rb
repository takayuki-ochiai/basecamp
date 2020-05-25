# frozen_string_literal: true

class CreateCalendar < ActiveRecord::Migration[6.0]
  def change
    create_table :calendars do |t|
      t.string      :title, null: false
      # ユーザーのプライベートなカレンダーとパブリックなカレンダーがあるのでSTIにする
      t.string      :type, null: false
      # nullになる可能性がある。パブリックなカレンダーがあるので
      t.references  :user
      t.timestamps
    end

    add_index :calendars, %i[user_id title], unique: true
  end
end
