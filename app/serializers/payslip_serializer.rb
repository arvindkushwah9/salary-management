class PayslipSerializer
  def initialize(payslip)
    @payslip = payslip
  end

  def as_json
    {
      id: @payslip.id,
      payroll_run_id: @payslip.payroll_run_id,
      employee_id: @payslip.employee_id,
      working_days: @payslip.working_days,
      paid_days: @payslip.paid_days.to_f,
      gross_earnings: @payslip.gross_earnings.to_f,
      total_deductions: @payslip.total_deductions.to_f,
      net_pay: @payslip.net_pay.to_f,
      payment_status: @payslip.payment_status,
      payslip_pdf_url: @payslip.payslip_pdf_url,
      created_at: @payslip.created_at,
      updated_at: @payslip.updated_at
    }
  end
end