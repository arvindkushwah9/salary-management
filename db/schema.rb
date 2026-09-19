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

ActiveRecord::Schema[8.1].define(version: 2026_09_19_121252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "departments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "employees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.uuid "department_id", null: false
    t.string "designation"
    t.string "email", null: false
    t.string "employee_code", null: false
    t.string "first_name", null: false
    t.string "job_title"
    t.string "joined_date"
    t.string "last_name", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["country"], name: "index_employees_on_country"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["status"], name: "index_employees_on_status"
  end

  create_table "salary_structures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "base_salary", precision: 12, scale: 2, null: false
    t.decimal "conveyance_allowance", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.uuid "employee_id", null: false
    t.decimal "housing_allowance", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "special_allowance", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["currency"], name: "index_salary_structures_on_currency"
    t.index ["employee_id", "effective_from"], name: "index_salary_structures_on_employee_id_and_effective_from"
    t.index ["employee_id"], name: "index_salary_structures_on_employee_id"
    t.check_constraint "base_salary >= 0::numeric", name: "salary_structures_base_salary_non_negative"
    t.check_constraint "conveyance_allowance >= 0::numeric", name: "salary_structures_conveyance_allowance_non_negative"
    t.check_constraint "effective_to IS NULL OR effective_to >= effective_from", name: "salary_structures_valid_date_range"
    t.check_constraint "housing_allowance >= 0::numeric", name: "salary_structures_housing_allowance_non_negative"
    t.check_constraint "special_allowance >= 0::numeric", name: "salary_structures_special_allowance_non_negative"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "hr_manager", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "employees", "departments"
  add_foreign_key "salary_structures", "employees"
end
