class CreatePayrollRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :payroll_runs, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :payroll_period, null: false, limit: 7
      t.string :status, null: false, default: "draft"

      t.decimal :total_gross,
                precision: 14,
                scale: 2,
                null: false,
                default: 0

      t.decimal :total_deductions,
                precision: 14,
                scale: 2,
                null: false,
                default: 0

      t.decimal :total_net,
                precision: 14,
                scale: 2,
                null: false,
                default: 0

      t.uuid :approved_by
      t.datetime :approved_at

      t.timestamps
    end

    add_index :payroll_runs, :payroll_period, unique: true
    add_index :payroll_runs, :status
  end
end