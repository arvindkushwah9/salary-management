class AddCurrencyToPayrollRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :payroll_runs, :currency, :string, limit: 3, null: false, default: "USD"

    add_index :payroll_runs, :currency
  end
end