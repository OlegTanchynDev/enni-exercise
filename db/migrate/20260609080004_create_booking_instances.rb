# frozen_string_literal: true

class CreateBookingInstances < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_instances do |t|
      t.references :facility, null: false, foreign_key: true
      t.references :customer, null: true, foreign_key: { to_table: :users }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :status, null: false, default: "provisional"
      # verification_status ships as a plain column; the candidate adds the AASM.
      t.string :verification_status, null: false, default: "unverified"

      t.timestamps
    end

    add_index :booking_instances, :status
    add_index :booking_instances, :verification_status
    add_index :booking_instances, :starts_at
  end
end
