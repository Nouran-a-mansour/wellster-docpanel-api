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

ActiveRecord::Schema[8.1].define(version: 2026_04_26_100513) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "doctor_id"
    t.bigint "patient_id"
    t.datetime "scheduled_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
  end

  create_table "doctor_indications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "doctor_id", null: false
    t.bigint "indication_id", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "indication_id"], name: "index_doctor_indications_on_doctor_id_and_indication_id", unique: true
    t.index ["doctor_id"], name: "index_doctor_indications_on_doctor_id"
    t.index ["indication_id"], name: "index_doctor_indications_on_indication_id"
  end

  create_table "doctors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_doctors_on_email", unique: true
  end

  create_table "indications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_indications_on_name", unique: true
  end

  create_table "patients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "doctor_id"
    t.string "email", null: false
    t.string "first_name", null: false
    t.bigint "indication_id", null: false
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_patients_on_doctor_id"
    t.index ["email"], name: "index_patients_on_email", unique: true
    t.index ["indication_id"], name: "index_patients_on_indication_id"
  end

  add_foreign_key "appointments", "doctors"
  add_foreign_key "appointments", "patients"
  add_foreign_key "doctor_indications", "doctors"
  add_foreign_key "doctor_indications", "indications"
  add_foreign_key "patients", "doctors"
  add_foreign_key "patients", "indications"
end
