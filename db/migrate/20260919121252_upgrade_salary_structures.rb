class UpgradeSalaryStructures < ActiveRecord::Migration[8.1]
  def up

  add_column :salary_structures, :effective_to, :date

  add_column :salary_structures, :housing_allowance,
             :decimal, precision: 12, scale: 2, null: false, default: 0

  add_column :salary_structures, :conveyance_allowance,
             :decimal, precision: 12, scale: 2, null: false, default: 0

  add_column :salary_structures, :special_allowance,
             :decimal, precision: 12, scale: 2, null: false, default: 0

  change_column :salary_structures, :base_salary,
                :decimal, precision: 12, scale: 2, null: false

  add_check_constraint :salary_structures,
                       "base_salary >= 0",
                       name: "salary_structures_base_salary_non_negative"

  add_check_constraint :salary_structures,
                       "housing_allowance >= 0",
                       name: "salary_structures_housing_allowance_non_negative"

  add_check_constraint :salary_structures,
                       "conveyance_allowance >= 0",
                       name: "salary_structures_conveyance_allowance_non_negative"

  add_check_constraint :salary_structures,
                       "special_allowance >= 0",
                       name: "salary_structures_special_allowance_non_negative"

  add_check_constraint :salary_structures,
                       "effective_to IS NULL OR effective_to >= effective_from",
                       name: "salary_structures_valid_date_range"
end
end