require "swagger_helper"

RSpec.describe "Payroll Runs API", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/payroll_runs" do
    get "List payroll runs" do
      tags "Payroll Runs"
      produces "application/json"

      parameter name: :Authorization,
                in: :header,
                required: true,
                schema: {
                  type: :string
                }

      security [bearerAuth: []]

      response "200", "payroll runs found" do
        let!(:older_run) do
          create(
            :payroll_run,
            payroll_period: "2026-08"
          )
        end

        let!(:newer_run) do
          create(
            :payroll_run,
            payroll_period: "2026-09"
          )
        end

        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: {
                         type: :string,
                         format: :uuid
                       },
                       payroll_period: {
                         type: :string,
                         example: "2026-09"
                       },
                       status: {
                         type: :string,
                         example: "draft"
                       },
                       total_gross: {
                         type: :number
                       },
                       total_deductions: {
                         type: :number
                       },
                       total_net: {
                         type: :number
                       },
                       approved_by: {
                         type: :string,
                         format: :uuid,
                         nullable: true
                       },
                       approved_at: {
                         type: :string,
                         format: "date-time",
                         nullable: true
                       }
                     },
                     required: %w[
                       id
                       payroll_period
                       status
                       total_gross
                       total_deductions
                       total_net
                     ]
                   }
                 }
               },
               required: ["data"]

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(body["data"].size).to eq(2)
          expect(body["data"].first["payroll_period"]).to eq("2026-09")
        end
      end

      response "401", "authentication required" do
        let(:Authorization) { nil }

        run_test!
      end
    end

    path "/api/v1/payroll_runs/{id}" do
      parameter name: :id,
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid
                }

      get "Show payroll run" do
        tags "Payroll Runs"
        produces "application/json"

        parameter name: :Authorization,
                  in: :header,
                  required: true,
                  schema: { type: :string }

        security [bearerAuth: []]

        response "200", "payroll run found" do
          let(:payroll_run) { create(:payroll_run) }
          let(:id) { payroll_run.id }

          run_test! do |response|
            body = JSON.parse(response.body)

            expect(body["data"]["id"]).to eq(payroll_run.id)
            expect(body["data"]["payroll_period"]).to eq(
              payroll_run.payroll_period
            )
          end
        end

        response "404", "payroll run not found" do
          let(:id) { SecureRandom.uuid }

          run_test!
        end
      end
    end

    path "/api/v1/payroll_runs" do
      post "Create payroll run" do
        tags "Payroll Runs"
        consumes "application/json"
        produces "application/json"

        parameter name: :Authorization,
                  in: :header,
                  required: true,
                  schema: { type: :string }

        parameter name: :payroll_run,
                  in: :body,
                  required: true,
                  schema: {
                    type: :object,
                    properties: {
                      payroll_run: {
                        type: :object,
                        properties: {
                          payroll_period: {
                            type: :string,
                            example: "2026-09"
                          }
                        },
                        required: ["payroll_period"]
                      }
                    }
                  }

        security [bearerAuth: []]

        response "201", "payroll run created" do
          let(:payroll_run) do
            {
              payroll_run: {
                payroll_period: "2026-09"
              }
            }
          end

          run_test! do |response|
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:created)
            expect(body["data"]["payroll_period"]).to eq("2026-09")
            expect(body["data"]["status"]).to eq("draft")

            expect(
              PayrollRun.find_by(payroll_period: "2026-09")
            ).to be_present
          end
        end

        response "422", "invalid payroll period" do
          let(:payroll_run) do
            {
              payroll_run: {
                payroll_period: "2026-99"
              }
            }
          end

          run_test! do |response|
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(body["error"]["code"]).to eq("VALIDATION_ERROR")
          end
        end

        response "422", "duplicate payroll period" do
          let!(:existing_payroll_run) do
            create(
              :payroll_run,
              payroll_period: "2026-09"
            )
          end

          let(:payroll_run) do
            {
              payroll_run: {
                payroll_period: "2026-09"
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_entity)

            body = JSON.parse(response.body)

            expect(body["error"]["code"]).to eq("VALIDATION_ERROR")
          end
        end
      end
    end

    path "/api/v1/payroll_runs/{id}" do
      parameter name: :id,
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid
                }

      patch "Update payroll run" do
        tags "Payroll Runs"
        consumes "application/json"
        produces "application/json"

        parameter name: :Authorization,
                  in: :header,
                  required: true,
                  schema: { type: :string }

        parameter name: :payroll_run,
                  in: :body,
                  required: true,
                  schema: {
                    type: :object,
                    properties: {
                      payroll_run: {
                        type: :object,
                        properties: {
                          payroll_period: {
                            type: :string,
                            example: "2026-10"
                          }
                        }
                      }
                    }
                  }

        security [bearerAuth: []]

        response "200", "payroll run updated" do
          let(:payroll_run_record) do
            create(:payroll_run, payroll_period: "2026-09")
          end

          let(:id) { payroll_run_record.id }

          let(:payroll_run) do
            {
              payroll_run: {
                payroll_period: "2026-10"
              }
            }
          end

          run_test! do |response|
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body["data"]["payroll_period"]).to eq("2026-10")

            expect(
              payroll_run_record.reload.payroll_period
            ).to eq("2026-10")
          end
        end
      end
    end

    path "/api/v1/payroll_runs/{id}" do
      parameter name: :id,
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid
                }

      delete "Delete payroll run" do
        tags "Payroll Runs"
        produces "application/json"

        parameter name: :Authorization,
                  in: :header,
                  required: true,
                  schema: { type: :string }

        security [bearerAuth: []]

        response "204", "payroll run deleted" do
          let(:payroll_run) { create(:payroll_run) }
          let(:id) { payroll_run.id }

          run_test! do
            expect(response).to have_http_status(:no_content)
            expect(PayrollRun.exists?(id)).to be(false)
          end
        end
      end
    end

    path "/api/v1/payroll_runs/{id}/approve" do
      parameter name: :id,
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid
                }

      post "Approve payroll run" do
        tags "Payroll Runs"
        produces "application/json"

        parameter name: :Authorization,
                  in: :header,
                  required: true,
                  schema: { type: :string }

        security [bearerAuth: []]

        response "200", "payroll run approved" do
          let(:payroll_run) { create(:payroll_run, status: "processing") }
          let(:id) { payroll_run.id }

          run_test! do |response|
            body = JSON.parse(response.body)

            expect(response).to have_http_status(:ok)
            expect(body["data"]["status"]).to eq("approved")
            expect(body["data"]["approved_by"]).to eq(user.id)

            payroll_run.reload

            expect(payroll_run.status).to eq("approved")
            expect(payroll_run.approved_by).to eq(user.id)
            expect(payroll_run.approved_at).to be_present
          end
        end
      end
    end

    path "/api/v1/payroll_runs/{id}/process" do
      post "Process a payroll run" do
        tags "Payroll Runs"
        consumes "application/json"
        produces "application/json"

        parameter name: :id,
                  in: :path,
                  required: true,
                  schema: { type: :string, format: :uuid }

        parameter name: :Authorization,
                  in: :header,
                  required: true,
                  schema: { type: :string }

        security [bearerAuth: []]

        response "200", "payroll processed successfully" do
          schema type: :object,
                 properties: {
                   data: {
                     type: :object,
                     properties: {
                       id: { type: :string, format: :uuid },
                       payroll_period: { type: :string },
                       status: { type: :string },
                       total_gross: { type: :number },
                       total_deductions: { type: :number },
                       total_net: { type: :number }
                     },
                     required: %w[
                       id
                       payroll_period
                       status
                       total_gross
                       total_deductions
                       total_net
                     ]
                   }
                 }

          let(:user) { create(:user) }
          let(:token) { JsonWebToken.encode(user_id: user.id) }
          let(:Authorization) { "Bearer #{token}" }

          let(:employee) { create(:employee, status: "active") }

          let!(:salary_structure) do
            create(
              :salary_structure,
              employee: employee,
              base_salary: 100_000,
              housing_allowance: 10_000,
              conveyance_allowance: 5_000,
              special_allowance: 5_000,
              currency: "USD",
              effective_from: Date.new(2026, 1, 1)
            )
          end

          let(:payroll_run) do
            create(
              :payroll_run,
              payroll_period: "2026-09",
              status: "draft"
            )
          end

          let(:id) { payroll_run.id }

          run_test! do |response|
            body = JSON.parse(response.body)

            expect(body["data"]["status"]).to eq("approved")
            expect(body["data"]["total_gross"]).to eq(120_000.0)
            expect(body["data"]["total_deductions"]).to eq(0.0)
            expect(body["data"]["total_net"]).to eq(120_000.0)

            expect(
              payroll_run.reload.payslips.exists?(employee: employee)
            ).to be(true)
          end
        end
      end
    end
  end
end