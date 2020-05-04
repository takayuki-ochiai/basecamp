class CreateInvitees < ActiveRecord::Migration[6.0]
  def change
    create_table :invitees do |t|
      t.references :schedule,  foreign_key: true
      t.references :invitable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
