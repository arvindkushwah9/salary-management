require "swagger_helper"

RSpec.describe "Salary Structures API", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }
  path "/api/v1/employees/{employee_id}/salary_structures" do
    parameter name: :employee_id,
              in: :path,
              type: :string,
              format: :uuid,
              required: true

    get "List Salary Structures" do
      tags "Salary Structures"
      security [bearerAuth: []]
      produces "application/json"

      response "200", "Salary Structures found" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }

        let!(:older_salary) do
          create(
            :salary_structure,
            employee: employee,
            base_salary: 90_000,
            currency: "USD",
            effective_from: Date.new(2025, 1, 1)
          )
        end

        let!(:current_salary) do
          create(
            :salary_structure,
            employee: employee,
            base_salary: 110_000,
            currency: "USD",
            effective_from: Date.new(2026, 1, 1)
          )
        end

        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string, format: :uuid },
                  employee_id: { type: :string, format: :uuid },
                  base_salary: { type: :number },
                  currency: { type: :string },
                  effective_from: { type: :string, format: :date }
                },
                required: %w[
                  id
                  employee_id
                  base_salary
                  currency
                  effective_from
                ]
              }
            }
          },
          required: ["data"]

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(body["data"].length).to eq(2)
          expect(body["data"].first["effective_from"]).to eq("2026-01-01")
          expect(body["data"].last["effective_from"]).to eq("2025-01-01")
        end
      end

      response "404", "employee not found" do
        let(:employee_id) { SecureRandom.uuid }

        run_test!
      end
    end

    post "Create salary record" do
      tags "Salary Structures"
      security [bearerAuth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :salary_structure,
          in: :body,
          required: true,
          schema: {
            type: :object,
            properties: {
              base_salary: {
                type: :number,
                format: :double,
                minimum: 0
              },
              currency: {
                type: :string,
                minLength: 3,
                maxLength: 3
              },
              effective_from: {
                type: :string,
                format: :date
              }
            }
          }

      response "201", "salary record created" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }

        let(:salary_structure) do
          {
            salary_structure: {
              base_salary: 125_000,
              currency: "USD",
              effective_from: "2026-09-01"
            }
          }
        end

        run_test!
      end

      response "422", "invalid salary record" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }

        let(:salary_structure) do
          {
            salary_structure: {
              base_salary: -100,
              currency: "US",
              effective_from: ""
            }
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/employees/{employee_id}/salary_structures/{id}" do
    parameter name: :employee_id,
              in: :path,
              type: :string,
              format: :uuid,
              required: true

    parameter name: :id,
              in: :path,
              type: :string,
              format: :uuid,
              required: true

    get "Show salary record" do
      tags "Salary Structures"
      security [bearerAuth: []]
      produces "application/json"

      response "200", "salary record found" do
        let!(:employee) { create(:employee) }

        let!(:salary_structure) do
          create(
            :salary_structure,
            employee: employee,
            base_salary: 120_000,
            currency: "USD",
            effective_from: Date.new(2026, 1, 1)
          )
        end

        let(:employee_id) { employee.id }
        let(:id) { salary_structure.id }

        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string, format: :uuid },
                employee_id: { type: :string, format: :uuid },
                base_salary: { type: :number },
                currency: { type: :string },
                effective_from: { type: :string, format: :date }
              },
              required: %w[
                id
                employee_id
                base_salary
                currency
                effective_from
              ]
            }
          },
          required: ["data"]

        run_test!
      end

      response "404", "salary record not found" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }
        let(:id) { SecureRandom.uuid }

        run_test!
      end

      response "404", "salary record belongs to another employee" do
        let!(:employee) { create(:employee) }
        let!(:other_employee) { create(:employee) }

        let!(:salary_structure) do
          create(:salary_structure, employee: other_employee)
        end

        let(:employee_id) { employee.id }
        let(:id) { salary_structure.id }

        run_test!
      end
    end

    patch "Update salary record" do
      tags "Salary Structures"
      security [bearerAuth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :salary_structure,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    base_salary: {
                      type: :number,
                      format: :double,
                      minimum: 0
                    },
                    currency: {
                      type: :string,
                      minLength: 3,
                      maxLength: 3
                    },
                    effective_from: {
                      type: :string,
                      format: :date
                    }
                  }
                }

      response "200", "salary record updated" do
          let!(:employee) { create(:employee) }

          let!(:salary_structure_record) do
            create(
              :salary_structure,
              employee: employee,
              base_salary: 100_000,
              currency: "USD",
              effective_from: Date.new(2026, 1, 1)
            )
          end

          let(:employee_id) { employee.id }
          let(:id) { salary_structure_record.id }

          let(:salary_structure) do
            {
              salary_structure: {
                base_salary: 110_000,
                currency: "USD"
              }
            }
          end

          run_test!
        end

      response "422", "invalid salary record update" do
        let!(:employee) { create(:employee) }

        let!(:salary_structure_record) do
          create(
            :salary_structure,
            employee: employee,
            base_salary: 100_000,
            currency: "USD",
            effective_from: Date.new(2026, 1, 1)
          )
        end

        let(:employee_id) { employee.id }
        let(:id) { salary_structure_record.id }

        let(:salary_structure) do
          {
            salary_structure: {
              base_salary: -500
            }
          }
        end

        run_test!
      end
    end
  end
end