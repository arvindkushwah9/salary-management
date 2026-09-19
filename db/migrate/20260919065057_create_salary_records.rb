class CreateSalaryRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_structures, id: :uuid do |t|
      t.references :employee, null: false, foreign_key: true, type: :uuid
      t.decimal :base_salary, precision: 15, scale: 2, null: false
      t.string :currency, limit: 3, null: false
      t.date :effective_from, null: false

      t.timestamps
    end

    add_index :salary_structures, [:employee_id, :effective_from]
    add_index :salary_structures, :currency
  end
end