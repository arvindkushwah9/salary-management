class SalaryRecordSerializer
  def initialize(salary_record)
    @salary_record = salary_record
  end

  def as_json
    {
      id: @salary_record.id,
      employee_id: @salary_record.employee_id,
      amount: @salary_record.amount.to_f,
      currency: @salary_record.currency,
      effective_date: @salary_record.effective_date
    }
  end
end