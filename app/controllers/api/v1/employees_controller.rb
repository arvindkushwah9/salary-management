module Api
  module V1
    class EmployeesController < ApplicationController
      def index
        employees = Employee
          .search(params[:search])
          .by_country(params[:country])
          .by_department(params[:department])
          .by_status(params[:employment_status])
          .order(:last_name, :first_name)

        pagy, records = pagy(employees)

        render json: {
          data: records.map { |employee| EmployeeSerializer.new(employee).as_json },
          meta: {
            page: pagy.page,
            per_page: pagy.limit,
            total: pagy.count,
            pages: pagy.pages
          }
        }
      end

      def show
        employee = Employee.find(params[:id])

        render json: {
          data: EmployeeSerializer.new(employee).as_json
        }
      end

      def create
        employee = Employee.new(employee_params)

        if employee.save
          render json: {
            data: EmployeeSerializer.new(employee).as_json
          }, status: :created
        else
          render_validation_errors(employee)
        end
      end

      def update
        employee = Employee.find(params[:id])

        if employee.update(employee_params)
          render json: {
            data: EmployeeSerializer.new(employee).as_json
          }
        else
          render_validation_errors(employee)
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :employee_number,
          :first_name,
          :last_name,
          :email,
          :country,
          :department,
          :job_title,
          :employment_status
        )
      end

      def render_validation_errors(employee)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Employee could not be saved",
            details: employee.errors.to_hash
          }
        }, status: :unprocessable_entity
      end
    end
  end
end