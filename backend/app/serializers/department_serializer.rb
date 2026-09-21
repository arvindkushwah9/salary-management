class DepartmentSerializer
  def initialize(department)
    @department = department
  end

  def as_json
    {
      id: @department.id,
      code: @department.code,
      name: @department.name
    }
  end
end