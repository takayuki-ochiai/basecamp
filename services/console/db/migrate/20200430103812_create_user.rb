class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uid, null: false, unique: true
      # 通知用にemailは保持しないといけない
      t.string :email, unique: true
      t.timestamps
    end
  end
end
