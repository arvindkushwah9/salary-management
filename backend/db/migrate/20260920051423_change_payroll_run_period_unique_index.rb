class ChangePayrollRunPeriodUniqueIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :payroll_runs,
                 name: "index_payroll_runs_on_payroll_period"

    add_index :payroll_runs,
              [:payroll_period, :currency],
              unique: true,
              name: "index_payroll_runs_on_period_and_currency"
  end
end