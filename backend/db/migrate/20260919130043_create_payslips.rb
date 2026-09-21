class CreatePayslips < ActiveRecord::Migration[8.1]
  def change
    create_table :payslips, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :payroll_run,
                   null: false,
                   foreign_key: true,
                   type: :uuid

      t.references :employee,
                   null: false,
                   foreign_key: true,
                   type: :uuid

      t.integer :working_days, null: false

      t.decimal :paid_days,
                precision: 4,
                scale: 1,
                null: false

      t.decimal :gross_earnings,
                precision: 12,
                scale: 2,
                null: false

      t.decimal :total_deductions,
                precision: 12,
                scale: 2,
                null: false

      t.decimal :net_pay,
                precision: 12,
                scale: 2,
                null: false

      t.string :payment_status,
                null: false,
                default: "pending"

      t.text :payslip_pdf_url

      t.timestamps
    end

    add_index :payslips,
              [:payroll_run_id, :employee_id],
              unique: true
  end
end