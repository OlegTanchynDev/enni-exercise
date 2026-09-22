# frozen_string_literal: true

class CreateCleaningPhotos < ActiveRecord::Migration[7.2]
  def change
    create_table :cleaning_photos do |t|
      t.references :booking_instance, null: false, foreign_key: true
      t.references :uploaded_by, null: true, foreign_key: { to_table: :users }
      t.jsonb :image_data # Shrine attachment metadata column

      t.timestamps
    end
  end
end
