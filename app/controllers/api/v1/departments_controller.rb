module Api
  module V1
    class DepartmentsController < ApplicationController
      def index
        departments = Department.order(:name)

        render json: {
          data: departments.map do |department|
            DepartmentSerializer.new(department).as_json
          end
        }
      end
    end
  end
end