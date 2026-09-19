class CreateSalaryRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_records, id: :uuid do |t|
      t.references :employee, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.string :currency
      t.date :effective_date

      t.timestamps
    end
    add_index :salary_records, [:employee_id, :effective_date]
    add_index :salary_records, :currency
  end
end
