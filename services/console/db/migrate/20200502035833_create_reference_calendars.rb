class CreateReferenceCalendars < ActiveRecord::Migration[6.0]
  def change
    # 自分以外のユーザーで予定を閲覧中のカレンダーの情報を保存するテーブル
    create_table :reference_calendars do |t|
      t.references :user,     foreign_key: true
      t.references :calendar, foreign_key: true
      t.timestamps
    end
  end
end
