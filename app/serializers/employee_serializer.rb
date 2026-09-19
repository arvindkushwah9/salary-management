class EmployeeSerializer
  def initialize(employee)
    @employee = employee
  end

  def as_json
    {
      id: @employee.id,
      employee_number: @employee.employee_number,
      first_name: @employee.first_name,
      last_name: @employee.last_name,
      full_name: @employee.full_name,
      email: @employee.email,
      country: @employee.country,
      department: @employee.department,
      job_title: @employee.job_title,
      employment_status: @employee.employment_status
    }
  end
end