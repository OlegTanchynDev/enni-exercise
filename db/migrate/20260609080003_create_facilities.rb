# frozen_string_literal: true

class CreateFacilities < ActiveRecord::Migration[7.2]
  def change
    create_table :facilities do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :capacity

      t.timestamps
    end
  end
end
