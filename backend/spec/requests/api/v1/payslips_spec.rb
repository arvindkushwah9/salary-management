require "swagger_helper"

RSpec.describe "Payslips API", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/payroll_runs/{payroll_run_id}/payslips" do
    parameter name: :payroll_run_id,
              in: :path,
              required: true,
              schema: {
                type: :string,
                format: :uuid
              }

    get "List payslips for payroll run" do
      tags "Payslips"
      produces "application/json"

      parameter name: :Authorization,
                in: :header,
                required: true,
                schema: { type: :string }

      security [bearerAuth: []]

      response "200", "payslips found" do
        let(:payroll_run) { create(:payroll_run) }
        let(:payroll_run_id) { payroll_run.id }

        let!(:employee_one) { create(:employee) }
        let!(:employee_two) { create(:employee) }

        let!(:payslip_one) do
          create(
            :payslip,
            payroll_run: payroll_run,
            employee: employee_one,
            gross_earnings: 100_000
          )
        end

        let!(:payslip_two) do
          create(
            :payslip,
            payroll_run: payroll_run,
            employee: employee_two,
            gross_earnings: 120_000
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
                       payroll_run_id: {
                         type: :string,
                         format: :uuid
                       },
                       employee_id: {
                         type: :string,
                         format: :uuid
                       },
                       working_days: {
                         type: :integer
                       },
                       paid_days: {
                         type: :number
                       },
                       gross_earnings: {
                         type: :number
                       },
                       total_deductions: {
                         type: :number
                       },
                       net_pay: {
                         type: :number
                       },
                       payment_status: {
                         type: :string
                       },
                       payslip_pdf_url: {
                         type: :string,
                         nullable: true
                       }
                     },
                     required: %w[
                       id
                       payroll_run_id
                       employee_id
                       working_days
                       paid_days
                       gross_earnings
                       total_deductions
                       net_pay
                       payment_status
                     ]
                   }
                 }
               },
               required: ["data"]

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body["data"].size).to eq(2)

          expect(
            body["data"].map { |payslip| payslip["id"] }
          ).to contain_exactly(
            payslip_one.id,
            payslip_two.id
          )

          expect(
            body["data"].all? do |payslip|
              payslip["payroll_run_id"] == payroll_run.id
            end
          ).to be(true)
        end
      end

      response "401", "authentication required" do
        let(:payroll_run_id) { SecureRandom.uuid }
        let(:Authorization) { nil }

        run_test!
      end

      response "404", "payroll run not found" do
        let(:payroll_run_id) { SecureRandom.uuid }

        run_test!
      end
    end

      path "/api/v1/employees/{id}/payslips" do
        parameter name: :id,
                  in: :path,
                  required: true,
                  schema: {
                    type: :string,
                    format: :uuid
                  }

        get "List payslips for employee" do
          tags "Payslips"
          produces "application/json"

          parameter name: :Authorization,
                    in: :header,
                    required: true,
                    schema: { type: :string }

          security [bearerAuth: []]

          response "200", "employee payslips found" do
            let(:employee) { create(:employee) }
            let(:id) { employee.id }

            let!(:payroll_run_one) do
              create(:payroll_run, payroll_period: "2026-08")
            end

            let!(:payroll_run_two) do
              create(:payroll_run, payroll_period: "2026-09")
            end

            let!(:payslip_one) do
              create(
                :payslip,
                employee: employee,
                payroll_run: payroll_run_one
              )
            end

            let!(:payslip_two) do
              create(
                :payslip,
                employee: employee,
                payroll_run: payroll_run_two
              )
            end

            # Payslip belonging to another employee should not be returned.
            let!(:other_employee) { create(:employee) }

            let!(:other_payslip) do
              create(
                :payslip,
                employee: other_employee,
                payroll_run: payroll_run_two
              )
            end

            run_test! do |response|
              body = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(body["data"].size).to eq(2)

              expect(
                body["data"].map { |payslip| payslip["id"] }
              ).to contain_exactly(
                payslip_one.id,
                payslip_two.id
              )

              expect(
                body["data"].map { |payslip| payslip["employee_id"] }
              ).to all(eq(employee.id))
            end
          end

          response "401", "authentication required" do
            let(:id) { SecureRandom.uuid }
            let(:Authorization) { nil }

            run_test!
          end

          response "404", "employee not found" do
            let(:id) { SecureRandom.uuid }

            run_test!
          end
        end
      end

      path "/api/v1/payslips/{id}" do
        parameter name: :id,
                  in: :path,
                  required: true,
                  schema: {
                    type: :string,
                    format: :uuid
                  }

        get "Show payslip" do
          tags "Payslips"
          produces "application/json"

          parameter name: :Authorization,
                    in: :header,
                    required: true,
                    schema: { type: :string }

          security [bearerAuth: []]

          response "200", "payslip found" do
            let(:payslip) { create(:payslip) }
            let(:id) { payslip.id }

            run_test! do |response|
              body = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)

              expect(body["data"]["id"]).to eq(payslip.id)
              expect(body["data"]["payroll_run_id"]).to eq(
                payslip.payroll_run_id
              )
              expect(body["data"]["employee_id"]).to eq(
                payslip.employee_id
              )

              expect(body["data"]["gross_earnings"]).to eq(
                payslip.gross_earnings.to_f
              )

              expect(body["data"]["total_deductions"]).to eq(
                payslip.total_deductions.to_f
              )

              expect(body["data"]["net_pay"]).to eq(
                payslip.net_pay.to_f
              )

              expect(body["data"]["payment_status"]).to eq(
                payslip.payment_status
              )
            end
          end

          response "401", "authentication required" do
            let(:id) { SecureRandom.uuid }
            let(:Authorization) { nil }

            run_test!
          end

          response "404", "payslip not found" do
            let(:id) { SecureRandom.uuid }

            run_test!
          end
        end
      end
    end
  end