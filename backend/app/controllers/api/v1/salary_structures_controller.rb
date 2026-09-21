module Api
  module V1
    class SalaryStructuresController < ApplicationController
      before_action :set_employee
      before_action :set_salary_structure, only: %i[show update]

      def index
        salary_structures = @employee.salary_structures.latest_first

        render json: {
          data: salary_structures.map do |salary_structure|
            SalaryStructureSerializer.new(salary_structure).as_json
          end
        }
      end

      def show
        render json: {
          data: SalaryStructureSerializer.new(@salary_structure).as_json
        }
      end

      def create
        salary_structure = @employee.salary_structures.new(salary_structure_params)

        if salary_structure.save
          render json: {
            data: SalaryStructureSerializer.new(salary_structure).as_json
          }, status: :created
        else
          render_validation_errors(salary_structure)
        end
      end

      def update
        if @salary_structure.update(salary_structure_params)
          render json: {
            data: SalaryStructureSerializer.new(@salary_structure).as_json
          }
        else
          render_validation_errors(@salary_structure)
        end
      end

      private

      def set_employee
        @employee = Employee.find(params[:employee_id])
      end

      def set_salary_structure
        @salary_structure = @employee.salary_structures.find(params[:id])
      end

      def salary_structure_params
        params.require(:salary_structure).permit(
          :base_salary,
          :housing_allowance,
          :conveyance_allowance,
          :special_allowance,
          :currency,
          :effective_from,
          :effective_to
        )
      end

      def render_validation_errors(salary_structure)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Salary structure could not be saved",
            details: salary_structure.errors.to_hash
          }
        }, status: :unprocessable_entity
      end
    end
  end
end