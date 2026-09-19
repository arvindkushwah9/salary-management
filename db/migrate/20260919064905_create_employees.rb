class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees, id: :uuid do |t|
      t.string :employee_number
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :country
      t.string :department
      t.string :job_title
      t.string :employment_status

      t.timestamps
    end
    add_index :employees, :employee_number, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, :country
    add_index :employees, :department
    add_index :employees, :employment_status
  end
end
