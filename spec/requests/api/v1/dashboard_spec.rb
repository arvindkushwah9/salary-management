require "swagger_helper"

RSpec.describe "Dashboard API", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/dashboard" do
    get "Get dashboard summary" do
      tags "Dashboard"
      security [bearerAuth: []]
      produces "application/json"

      response "200", "dashboard summary returned" do
        let!(:us_employee) do
          create(
            :employee,
            country: "US",
            status: "active"
          )
        end

        let!(:uk_employee) do
          create(
            :employee,
            country: "UK",
            status: "active"
          )
        end

        let!(:terminated_employee) do
          create(
            :employee,
            country: "US",
            status: "terminated"
          )
        end

        let!(:us_salary) do
          create(
            :salary_structure,
            employee: us_employee,
            base_salary: 100_000,
            currency: "USD",
            effective_from: Date.new(2026, 1, 1)
          )
        end

        let!(:uk_salary) do
          create(
            :salary_structure,
            employee: uk_employee,
            base_salary: 80_000,
            currency: "GBP",
            effective_from: Date.new(2026, 1, 1)
          )
        end

        let!(:terminated_salary) do
          create(
            :salary_structure,
            employee: terminated_employee,
            base_salary: 90_000,
            currency: "USD",
            effective_from: Date.new(2026, 1, 1)
          )
        end

        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                employees: {
                  type: :object,
                  properties: {
                    total: { type: :integer },
                    active: { type: :integer },
                    inactive: { type: :integer }
                  },
                  required: %w[total active inactive]
                },
                countries: {
                  type: :object,
                  properties: {
                    count: { type: :integer },
                    employee_count_by_country: {
                      type: :object,
                      additionalProperties: { type: :integer }
                    }
                  },
                  required: %w[count employee_count_by_country]
                },
                salary: {
                  type: :object,
                  properties: {
                    employees_with_salary: { type: :integer },
                    currencies: {
                      type: :array,
                      items: { type: :string }
                    },
                    statistics_by_currency: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          currency: { type: :string },
                          minimum: { type: :number },
                          maximum: { type: :number },
                          average: { type: :number }
                        },
                        required: %w[
                          currency
                          minimum
                          maximum
                          average
                        ]
                      }
                    }
                  },
                  required: %w[
                    employees_with_salary
                    currencies
                    statistics_by_currency
                  ]
                }
              },
              required: %w[
                employees
                countries
                salary
              ]
            }
          },
          required: ["data"]

        run_test! do |response|
          body = JSON.parse(response.body)
          data = body.fetch("data")

          expect(data["employees"]).to eq(
            "total" => 3,
            "active" => 2,
            "inactive" => 1
          )

          expect(data["countries"]["count"]).to eq(2)

          expect(data["countries"]["employee_count_by_country"]).to eq(
            "UK" => 1,
            "US" => 2
          )

          expect(data["salary"]["employees_with_salary"]).to eq(3)

          expect(data["salary"]["currencies"]).to eq(
            %w[GBP USD]
          )

          statistics = data["salary"]["statistics_by_currency"]

          expect(statistics).to contain_exactly(
            {
              "currency" => "GBP",
              "minimum" => 80_000.0,
              "maximum" => 80_000.0,
              "average" => 80_000.0
            },
            {
              "currency" => "USD",
              "minimum" => 90_000.0,
              "maximum" => 100_000.0,
              "average" => 95_000.0
            }
          )
        end
      end
    end
  end
end