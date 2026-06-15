# frozen_string_literal: true

class AddProfileColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :type, :string # STI: SystemAdmin | OperatorUser | Customer
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :roles, :string, array: true, null: false, default: []
    add_reference :users, :operator, null: true, index: true
    add_index :users, :type
  end
end
