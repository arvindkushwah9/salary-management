class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments, id: :uuid do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :departments, :code, unique: true
    add_index :departments, :name, unique: true
  end
end