class EmployeeSerializer
  def initialize(employee)
    @employee = employee
  end

  def as_json
    {
      id: @employee.id,
      employee_code: @employee.employee_code,
      first_name: @employee.first_name,
      last_name: @employee.last_name,
      full_name: @employee.full_name,
      email: @employee.email,
      country: @employee.country,
      department: department_json,
      job_title: @employee.job_title,
      status: @employee.status,
      joined_date: @employee.joined_date
    }
  end

  def department_json
    department = @employee.department
    return nil unless department

    {
      id: department.id,
      code: department.code,
      name: department.name
    }
  end
end