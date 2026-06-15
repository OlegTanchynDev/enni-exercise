# frozen_string_literal: true

class CreateImageClassifications < ActiveRecord::Migration[7.2]
  def change
    create_table :image_classifications do |t|
      t.references :cleaning_photo, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.jsonb :result, null: false, default: {}
      t.boolean :passed
      t.string :error_message
      t.datetime :classified_at

      t.timestamps
    end

    add_index :image_classifications, :status
  end
end
