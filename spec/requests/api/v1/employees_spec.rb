require "swagger_helper"

RSpec.describe "Employees API", type: :request do
  path "/api/v1/employees" do
    get "List employees" do
      tags "Employees"
      produces "application/json"

      parameter name: :search,
                in: :query,
                type: :string,
                required: false

      parameter name: :country,
                in: :query,
                type: :string,
                required: false

      parameter name: :department,
                in: :query,
                type: :string,
                required: false

      parameter name: :employment_status,
                in: :query,
                type: :string,
                required: false

      parameter name: :page,
                in: :query,
                type: :integer,
                required: false

      parameter name: :per_page,
                in: :query,
                type: :integer,
                required: false

      response "200", "employees found" do
        schema type: :object,
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
                  email: { type: :string },
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

        let!(:employee) { create(:employee) }

        run_test!
      end
    end

    post "Create employee" do
      tags "Employees"
      consumes "application/json"
      produces "application/json"

      parameter name: :employee,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %w[
                    employee_number
                    first_name
                    last_name
                    email
                    country
                    employment_status
                  ],
                  properties: {
                    employee_number: { type: :string },
                    first_name: { type: :string },
                    last_name: { type: :string },
                    email: { type: :string },
                    country: { type: :string },
                    department: { type: :string },
                    job_title: { type: :string },
                    employment_status: { type: :string }
                  }
                }

      response "201", "employee created" do
        let(:employee) do
          {
            employee: {
              employee_number: "EMP-10001",
              first_name: "John",
              last_name: "Doe",
              email: "john.doe@example.com",
              country: "US",
              department: "Engineering",
              job_title: "Software Engineer",
              employment_status: "active"
            }
          }
        end

        run_test!
      end

      response "422", "invalid employee" do
        let(:employee) do
          {
            employee: {
              employee_number: "",
              first_name: "",
              last_name: "",
              email: "invalid",
              country: "",
              employment_status: ""
            }
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/employees/{id}" do
    parameter name: :id,
              in: :path,
              type: :string,
              format: :uuid,
              required: true

    get "Show employee" do
      tags "Employees"
      produces "application/json"

      response "200", "employee found" do
        let!(:employee_record) { create(:employee) }
        let(:id) { employee_record.id }

        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string, format: :uuid },
                employee_number: { type: :string },
                first_name: { type: :string },
                last_name: { type: :string },
                full_name: { type: :string },
                email: { type: :string },
                country: { type: :string },
                department: { type: :string, nullable: true },
                job_title: { type: :string, nullable: true },
                employment_status: { type: :string }
              }
            }
          },
          required: ["data"]

        run_test!
      end

      response "404", "employee not found" do
        let(:id) { SecureRandom.uuid }

        run_test!
      end
    end

    patch "Update employee" do
      tags "Employees"
      consumes "application/json"
      produces "application/json"

      parameter name: :employee,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    first_name: { type: :string },
                    last_name: { type: :string },
                    email: { type: :string },
                    country: { type: :string },
                    department: { type: :string },
                    job_title: { type: :string },
                    employment_status: { type: :string }
                  }
                }

      response "200", "employee updated" do
        let!(:employee_record) { create(:employee) }
        let(:id) { employee_record.id }

        let(:employee) do
          {
            employee: {
              department: "Product",
              job_title: "Senior Software Engineer"
            }
          }
        end

        run_test!
      end

      response "422", "invalid employee update" do
        let!(:employee_record) { create(:employee) }
        let(:id) { employee_record.id }

        let(:employee) do
          {
            employee: {
              email: "invalid"
            }
          }
        end

        run_test!
      end

      response "404", "employee not found" do
        let(:id) { SecureRandom.uuid }

        let(:employee) do
          {
            employee: {
              department: "Product"
            }
          }
        end

        run_test!
      end
    end
  end
end