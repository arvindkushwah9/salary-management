require "swagger_helper"

RSpec.describe "Employees API", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/employees" do
    get "List employees" do
      tags "Employees"
      security [bearerAuth: []]
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

      parameter name: :status,
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
                  employee_code: { type: :string },
                  first_name: { type: :string },
                  last_name: { type: :string },
                  full_name: { type: :string },
                  email: { type: :string },
                  country: { type: :string },

                  department: {
                    type: :object,
                    nullable: true,
                    properties: {
                      id: { type: :string, format: :uuid },
                      code: { type: :string },
                      name: { type: :string },
                      created_at: { type: :string, format: "date-time" },
                      updated_at: { type: :string, format: "date-time" }
                    },
                    required: %w[id code name]
                  },

                  designation: { type: :string },
                  status: { type: :string },
                  joined_date: { type: :string }
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
      security [bearerAuth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :employee,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %w[
                    employee_code
                    first_name
                    last_name
                    email
                    department_id
                    designation
                    country
                    status
                    joined_date
                  ],
                  properties: {
                    employee_code: { type: :string },
                    first_name: { type: :string },
                    last_name: { type: :string },
                    email: { type: :string },

                    department_id: {
                      type: :string,
                      format: :uuid
                    },

                    designation: { type: :string },
                    country: { type: :string },
                    status: { type: :string },
                    joined_date: { type: :string }
                  }
                }

      response "201", "employee created" do
        let!(:department) do
          create(:department, name: "Engineering")
        end

        let(:employee) do
          {
            employee: {
              employee_code: "EMP-10001",
              first_name: "John",
              last_name: "Doe",
              email: "john.doe@example.com",
              department_id: department.id,
              designation: "Software Engineer",
              country: "US",
              status: "active",
              joined_date: Date.current
            }
          }
        end

        run_test!
      end

      response "422", "invalid employee" do
        let!(:department) do
          create(:department)
        end

        let(:employee) do
          {
            employee: {
              employee_code: "",
              first_name: "",
              last_name: "",
              email: "invalid",
              department_id: department.id,
              designation: "",
              country: "",
              status: "",
              joined_date: ""
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
      security [bearerAuth: []]
      produces "application/json"

      response "200", "employee found" do
        let!(:employee_structure) { create(:employee) }
        let(:id) { employee_structure.id }

        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string, format: :uuid },
                employee_code: { type: :string },
                first_name: { type: :string },
                last_name: { type: :string },
                full_name: { type: :string },
                email: { type: :string },
                country: { type: :string },

                department: {
                  type: :object,
                  nullable: true,
                  properties: {
                    id: { type: :string, format: :uuid },
                    code: { type: :string },
                    name: { type: :string },
                    created_at: { type: :string, format: "date-time" },
                    updated_at: { type: :string, format: "date-time" }
                  },
                  required: %w[id code name]
                },

                designation: { type: :string },
                status: { type: :string },
                joined_date: { type: :string }
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
      security [bearerAuth: []]
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

                    department_id: {
                      type: :string,
                      format: :uuid
                    },

                    designation: { type: :string },
                    country: { type: :string },
                    status: { type: :string },
                    joined_date: { type: :string }
                  }
                }

      response "200", "employee updated" do
        let!(:employee_structure) { create(:employee) }
        let!(:department) do
          create(:department, name: "Product")
        end

        let(:id) { employee_structure.id }

        let(:employee) do
          {
            employee: {
              department_id: department.id,
              designation: "Senior Software Engineer"
            }
          }
        end

        run_test!
      end

      response "422", "invalid employee update" do
        let!(:employee_structure) { create(:employee) }
        let(:id) { employee_structure.id }

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

        let!(:department) do
          create(:department, name: "Product")
        end

        let(:employee) do
          {
            employee: {
              department_id: department.id
            }
          }
        end

        run_test!
      end
    end
  end
end