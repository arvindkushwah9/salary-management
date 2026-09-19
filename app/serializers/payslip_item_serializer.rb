class PayslipItemSerializer
  def initialize(payslip_item)
    @payslip_item = payslip_item
  end

  def as_json
    {
      id: @payslip_item.id,
      payslip_id: @payslip_item.payslip_id,
      item_type: @payslip_item.item_type,
      code: @payslip_item.code,
      description: @payslip_item.description,
      amount: @payslip_item.amount.to_f,
      created_at: @payslip_item.created_at,
      updated_at: @payslip_item.updated_at
    }
  end
end