class CreatePayslipItems < ActiveRecord::Migration[8.1]
  def change
    create_table :payslip_items, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :payslip,
                   null: false,
                   foreign_key: true,
                   type: :uuid

      t.string :item_type,
                null: false,
                limit: 20

      t.string :code,
                null: false,
                limit: 30

      t.string :description,
                limit: 100

      t.decimal :amount,
                precision: 12,
                scale: 2,
                null: false

      t.timestamps
    end

    add_index :payslip_items,
              [:payslip_id, :item_type]

    add_index :payslip_items,
              [:payslip_id, :code]
  end
end