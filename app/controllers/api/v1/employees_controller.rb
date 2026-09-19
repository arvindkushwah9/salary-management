module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :set_employee, only: %i[show update]

      def index
        employees = Employee
          .search(params[:search])
          .by_country(params[:country])
          .by_department(params[:department])
          .then { |scope| filter_by_status(scope) }
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
        render json: employee_json(@employee, include_salary: true)
      end

      def create
        employee = Employee.new(employee_params)

        if employee.save
          render json: employee_json(employee), status: :created
        else
          render_validation_errors(employee)
        end
      end

      def update
        if @employee.update(employee_params)
          render json: employee_json(@employee)
        else
          render_validation_errors(@employee)
        end
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

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

      def filter_by_status(scope)
        return scope if params[:employment_status].blank?

        scope.where(employment_status: params[:employment_status])
      end

      def employee_json(employee, include_salary: false)
        data = {
          id: employee.id,
          employee_number: employee.employee_number,
          first_name: employee.first_name,
          last_name: employee.last_name,
          full_name: employee.full_name,
          email: employee.email,
          country: employee.country,
          department: employee.department,
          job_title: employee.job_title,
          employment_status: employee.employment_status
        }

        if include_salary
          salary = employee.current_salary

          data[:current_salary] = salary && {
            id: salary.id,
            amount: salary.amount.to_s,
            currency: salary.currency,
            effective_date: salary.effective_date
          }
        end

        data
      end

      def render_validation_errors(record)
        render json: {
          errors: record.errors.to_hash
        }, status: :unprocessable_entity
      end
    end
  end
end