class SalaryStructureSerializer
  def initialize(salary_structure)
    @salary_structure = salary_structure
  end

  def as_json
    {
      id: @salary_structure.id,
      employee_id: @salary_structure.employee_id,
      base_salary: @salary_structure.base_salary.to_f,
      housing_allowance: @salary_structure.housing_allowance.to_f,
      conveyance_allowance: @salary_structure.conveyance_allowance.to_f,
      special_allowance: @salary_structure.special_allowance.to_f,
      gross_salary: @salary_structure.gross_salary.to_f,
      currency: @salary_structure.currency,
      effective_from: @salary_structure.effective_from,
      effective_to: @salary_structure.effective_to
    }
  end
end