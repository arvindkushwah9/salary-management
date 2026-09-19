require "swagger_helper"

RSpec.describe "Salary Records API", type: :request do
  path "/api/v1/employees/{employee_id}/salary_records" do
    parameter name: :employee_id,
              in: :path,
              type: :string,
              format: :uuid,
              required: true

    get "List salary records" do
      tags "Salary Records"
      produces "application/json"

      response "200", "salary records found" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }

        let!(:older_salary) do
          create(
            :salary_record,
            employee: employee,
            amount: 90_000,
            currency: "USD",
            effective_date: Date.new(2025, 1, 1)
          )
        end

        let!(:current_salary) do
          create(
            :salary_record,
            employee: employee,
            amount: 110_000,
            currency: "USD",
            effective_date: Date.new(2026, 1, 1)
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
                  amount: { type: :number },
                  currency: { type: :string },
                  effective_date: { type: :string, format: :date }
                },
                required: %w[
                  id
                  employee_id
                  amount
                  currency
                  effective_date
                ]
              }
            }
          },
          required: ["data"]

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(body["data"].length).to eq(2)
          expect(body["data"].first["effective_date"]).to eq("2026-01-01")
          expect(body["data"].last["effective_date"]).to eq("2025-01-01")
        end
      end

      response "404", "employee not found" do
        let(:employee_id) { SecureRandom.uuid }

        run_test!
      end
    end

    post "Create salary record" do
      tags "Salary Records"
      consumes "application/json"
      produces "application/json"

      parameter name: :salary_record,
          in: :body,
          required: true,
          schema: {
            type: :object,
            properties: {
              amount: {
                type: :number,
                format: :double,
                minimum: 0
              },
              currency: {
                type: :string,
                minLength: 3,
                maxLength: 3
              },
              effective_date: {
                type: :string,
                format: :date
              }
            }
          }

      response "201", "salary record created" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }

        let(:salary_record) do
          {
            salary_record: {
              amount: 125_000,
              currency: "USD",
              effective_date: "2026-09-01"
            }
          }
        end

        run_test!
      end

      response "422", "invalid salary record" do
        let!(:employee) { create(:employee) }
        let(:employee_id) { employee.id }

        let(:salary_record) do
          {
            salary_record: {
              amount: -100,
              currency: "US",
              effective_date: ""
            }
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/employees/{employee_id}/salary_records/{id}" do
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
      tags "Salary Records"
      produces "application/json"

      response "200", "salary record found" do
        let!(:employee) { create(:employee) }

        let!(:salary_record) do
          create(
            :salary_record,
            employee: employee,
            amount: 120_000,
            currency: "USD",
            effective_date: Date.new(2026, 1, 1)
          )
        end

        let(:employee_id) { employee.id }
        let(:id) { salary_record.id }

        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string, format: :uuid },
                employee_id: { type: :string, format: :uuid },
                amount: { type: :number },
                currency: { type: :string },
                effective_date: { type: :string, format: :date }
              },
              required: %w[
                id
                employee_id
                amount
                currency
                effective_date
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

        let!(:salary_record) do
          create(:salary_record, employee: other_employee)
        end

        let(:employee_id) { employee.id }
        let(:id) { salary_record.id }

        run_test!
      end
    end

    patch "Update salary record" do
      tags "Salary Records"
      consumes "application/json"
      produces "application/json"

      parameter name: :salary_record,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    amount: {
                      type: :number,
                      format: :double,
                      minimum: 0
                    },
                    currency: {
                      type: :string,
                      minLength: 3,
                      maxLength: 3
                    },
                    effective_date: {
                      type: :string,
                      format: :date
                    }
                  }
                }

      response "200", "salary record updated" do
          let!(:employee) { create(:employee) }

          let!(:salary_record_record) do
            create(
              :salary_record,
              employee: employee,
              amount: 100_000,
              currency: "USD",
              effective_date: Date.new(2026, 1, 1)
            )
          end

          let(:employee_id) { employee.id }
          let(:id) { salary_record_record.id }

          let(:salary_record) do
            {
              salary_record: {
                amount: 110_000,
                currency: "USD"
              }
            }
          end

          run_test!
        end

      response "422", "invalid salary record update" do
        let!(:employee) { create(:employee) }

        let!(:salary_record_record) do
          create(
            :salary_record,
            employee: employee,
            amount: 100_000,
            currency: "USD",
            effective_date: Date.new(2026, 1, 1)
          )
        end

        let(:employee_id) { employee.id }
        let(:id) { salary_record_record.id }

        let(:salary_record) do
          {
            salary_record: {
              amount: -500
            }
          }
        end

        run_test!
      end
    end
  end
end