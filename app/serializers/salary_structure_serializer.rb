class SalaryStructureSerializer
  def initialize(salary_structure)
    @salary_structure = salary_structure
  end

  def as_json
    {
      id: @salary_structure.id,
      employee_id: @salary_structure.employee_id,
      base_salary: @salary_structure.base_salary.to_f,
      currency: @salary_structure.currency,
      effective_from: @salary_structure.effective_from
    }
  end
end