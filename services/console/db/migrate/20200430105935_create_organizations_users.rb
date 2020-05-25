# frozen_string_literal: true

class CreateOrganizationsUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations_users do |t|
      t.references  :user,         foreign_key: true
      t.references  :organization, foreign_key: true
      t.timestamps
    end

    add_index :organizations_users, %i[user_id organization_id], unique: true
    add_index :organizations_users, %i[organization_id user_id], unique: true
  end
end
