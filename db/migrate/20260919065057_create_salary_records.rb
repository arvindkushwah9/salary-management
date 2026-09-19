class CreateSalaryRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_records, id: :uuid do |t|
      t.references :employee, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :currency, limit: 3, null: false
      t.date :effective_date, null: false

      t.timestamps
    end

    add_index :salary_records, [:employee_id, :effective_date]
    add_index :salary_records, :currency
  end
end