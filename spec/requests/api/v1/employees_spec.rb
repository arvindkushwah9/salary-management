require "swagger_helper"

RSpec.describe "Employees API", type: :request do
  path "/api/v1/employees" do
    get "List employees" do
      tags "Employees"
      produces "application/json"

      parameter(
        name: :search,
        in: :query,
        required: false,
        schema: {
          type: :string
        }
      )

      parameter(
        name: :country,
        in: :query,
        required: false,
        schema: {
          type: :string
        }
      )

      parameter(
        name: :department,
        in: :query,
        required: false,
        schema: {
          type: :string
        }
      )

      parameter(
        name: :employment_status,
        in: :query,
        required: false,
        schema: {
          type: :string
        }
      )

      parameter(
        name: :page,
        in: :query,
        required: false,
        schema: {
          type: :integer,
          minimum: 1
        }
      )

      parameter(
        name: :per_page,
        in: :query,
        required: false,
        schema: {
          type: :integer,
          minimum: 1,
          maximum: 100
        }
      )

      response "200", "employees found" do
        schema(
          type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string, format: :uuid },
                  employee_number: { type: :string },
                  first_name: { type: :string },
                  last_name: { type: :string },
                  full_name: { type: :string },
                  email: { type: :string, format: :email },
                  country: { type: :string },
                  department: { type: :string, nullable: true },
                  job_title: { type: :string, nullable: true },
                  employment_status: { type: :string }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                page: { type: :integer },
                per_page: { type: :integer },
                total: { type: :integer },
                pages: { type: :integer }
              }
            }
          },
          required: %w[data meta]
        )

        let(:search) { nil }
        let(:country) { nil }
        let(:department) { nil }
        let(:employment_status) { nil }
        let(:page) { 1 }
        let(:per_page) { 25 }

        before do
          create_list(:employee, 3)
        end

        run_test!
      end
    end
  end
end