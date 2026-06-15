# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_06_09_080007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "booking_instances", force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "customer_id"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "status", default: "provisional", null: false
    t.string "verification_status", default: "unverified", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_booking_instances_on_customer_id"
    t.index ["facility_id"], name: "index_booking_instances_on_facility_id"
    t.index ["starts_at"], name: "index_booking_instances_on_starts_at"
    t.index ["status"], name: "index_booking_instances_on_status"
    t.index ["verification_status"], name: "index_booking_instances_on_verification_status"
  end

  create_table "cleaning_photos", force: :cascade do |t|
    t.bigint "booking_instance_id", null: false
    t.bigint "uploaded_by_id"
    t.jsonb "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_instance_id"], name: "index_cleaning_photos_on_booking_instance_id"
    t.index ["uploaded_by_id"], name: "index_cleaning_photos_on_uploaded_by_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "name", null: false
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["venue_id"], name: "index_facilities_on_venue_id"
  end

  create_table "image_classifications", force: :cascade do |t|
    t.bigint "cleaning_photo_id", null: false
    t.string "status", default: "pending", null: false
    t.jsonb "result", default: {}, null: false
    t.boolean "passed"
    t.string "error_message"
    t.datetime "classified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cleaning_photo_id"], name: "index_image_classifications_on_cleaning_photo_id"
    t.index ["status"], name: "index_image_classifications_on_status"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "operators", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_operators_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "name", default: "", null: false
    t.string "roles", default: [], null: false, array: true
    t.bigint "operator_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["operator_id"], name: "index_users_on_operator_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["type"], name: "index_users_on_type"
  end

  create_table "venues", force: :cascade do |t|
    t.bigint "operator_id", null: false
    t.string "name", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_venues_on_operator_id"
  end

  add_foreign_key "booking_instances", "facilities"
  add_foreign_key "booking_instances", "users", column: "customer_id"
  add_foreign_key "cleaning_photos", "booking_instances"
  add_foreign_key "cleaning_photos", "users", column: "uploaded_by_id"
  add_foreign_key "facilities", "venues"
  add_foreign_key "image_classifications", "cleaning_photos"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "users", "operators"
  add_foreign_key "venues", "operators"
end
