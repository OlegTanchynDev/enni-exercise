# frozen_string_literal: true

class CreateOperators < ActiveRecord::Migration[7.2]
  def change
    create_table :operators do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :operators, :slug, unique: true
  end
end
