# frozen_string_literal: true

class AddOperatorFkToUsers < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :users, :operators
  end
end
