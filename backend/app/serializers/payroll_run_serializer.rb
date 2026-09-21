class PayrollRunSerializer
  def initialize(payroll_run)
    @payroll_run = payroll_run
  end

  def as_json
    {
      id: @payroll_run.id,
      payroll_period: @payroll_run.payroll_period,
      currency: @payroll_run.currency,
      status: @payroll_run.status,
      total_gross: @payroll_run.total_gross.to_f,
      total_deductions: @payroll_run.total_deductions.to_f,
      total_net: @payroll_run.total_net.to_f,
      approved_by: @payroll_run.approved_by,
      approved_at: @payroll_run.approved_at,
      created_at: @payroll_run.created_at,
      updated_at: @payroll_run.updated_at
    }
  end
end