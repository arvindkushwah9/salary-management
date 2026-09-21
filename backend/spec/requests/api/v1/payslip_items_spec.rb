require "swagger_helper"

RSpec.describe "Payslip Items API", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/payslips/{payslip_id}/payslip_items" do
    parameter name: :payslip_id,
              in: :path,
              required: true,
              schema: {
                type: :string,
                format: :uuid
              }

    get "List payslip items" do
      tags "Payslip Items"
      produces "application/json"

      parameter name: :Authorization,
                in: :header,
                required: true,
                schema: { type: :string }

      security [bearerAuth: []]

      response "200", "payslip items found" do
        let(:payslip) { create(:payslip) }
        let(:payslip_id) { payslip.id }

        let!(:earning_item) do
          create(
            :payslip_item,
            payslip: payslip,
            item_type: "earning",
            code: "BASIC",
            description: "Base salary",
            amount: 100_000
          )
        end

        let!(:deduction_item) do
          create(
            :payslip_item,
            payslip: payslip,
            item_type: "deduction",
            code: "TAX",
            description: "Income tax",
            amount: 10_000
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
                       payslip_id: {
                         type: :string,
                         format: :uuid
                       },
                       item_type: {
                         type: :string,
                         example: "earning"
                       },
                       code: {
                         type: :string,
                         example: "BASIC"
                       },
                       description: {
                         type: :string,
                         nullable: true
                       },
                       amount: {
                         type: :number,
                         example: 100000.0
                       }
                     },
                     required: %w[
                       id
                       payslip_id
                       item_type
                       code
                       amount
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
            body["data"].map { |item| item["id"] }
          ).to contain_exactly(
            earning_item.id,
            deduction_item.id
          )

          expect(
            body["data"].all? do |item|
              item["payslip_id"] == payslip.id
            end
          ).to be(true)
        end
      end

      response "401", "authentication required" do
        let(:payslip_id) { SecureRandom.uuid }
        let(:Authorization) { nil }

        run_test!
      end

      response "404", "payslip not found" do
        let(:payslip_id) { SecureRandom.uuid }

        run_test!
      end
    end
  end

  path "/api/v1/payslips/{payslip_id}/payslip_items" do
    parameter name: :payslip_id,
              in: :path,
              required: true,
              schema: {
                type: :string,
                format: :uuid
              }

    post "Create payslip item" do
      tags "Payslip Items"
      consumes "application/json"
      produces "application/json"

      parameter name: :Authorization,
                in: :header,
                required: true,
                schema: { type: :string }

      parameter name: :payslip_item,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    payslip_item: {
                      type: :object,
                      properties: {
                        item_type: {
                          type: :string,
                          enum: %w[earning deduction statutory],
                          example: "earning"
                        },
                        code: {
                          type: :string,
                          example: "BONUS"
                        },
                        description: {
                          type: :string,
                          example: "Performance bonus"
                        },
                        amount: {
                          type: :number,
                          example: 15000.0
                        }
                      },
                      required: %w[
                        item_type
                        code
                        amount
                      ]
                    }
                  }
                }

      security [bearerAuth: []]

      response "201", "payslip item created" do
        let(:payslip) { create(:payslip) }
        let(:payslip_id) { payslip.id }

        let(:payslip_item) do
          {
            payslip_item: {
              item_type: "earning",
              code: "BONUS",
              description: "Performance bonus",
              amount: 15_000
            }
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)

          expect(body["data"]["payslip_id"]).to eq(payslip.id)
          expect(body["data"]["item_type"]).to eq("earning")
          expect(body["data"]["code"]).to eq("BONUS")
          expect(body["data"]["description"]).to eq("Performance bonus")
          expect(body["data"]["amount"]).to eq(15_000.0)

          expect(
            payslip.payslip_items.find_by(code: "BONUS")
          ).to be_present
        end
      end

      response "422", "invalid item type" do
        let(:payslip) { create(:payslip) }
        let(:payslip_id) { payslip.id }

        let(:payslip_item) do
          {
            payslip_item: {
              item_type: "invalid",
              code: "BONUS",
              description: "Invalid item",
              amount: 15_000
            }
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(body["error"]["code"]).to eq("VALIDATION_ERROR")
        end
      end

      response "422", "negative amount" do
        let(:payslip) { create(:payslip) }
        let(:payslip_id) { payslip.id }

        let(:payslip_item) do
          {
            payslip_item: {
              item_type: "deduction",
              code: "TAX",
              description: "Tax",
              amount: -100
            }
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(body["error"]["code"]).to eq("VALIDATION_ERROR")
        end
      end

      response "422", "missing required fields" do
        let(:payslip) { create(:payslip) }
        let(:payslip_id) { payslip.id }

        let(:payslip_item) do
          {
            payslip_item: {
              description: "Missing item type and code"
            }
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(body["error"]["code"]).to eq("VALIDATION_ERROR")
        end
      end

      response "401", "authentication required" do
        let(:payslip_id) { SecureRandom.uuid }
        let(:Authorization) { nil }

        let(:payslip_item) do
          {
            payslip_item: {
              item_type: "earning",
              code: "BONUS",
              amount: 15_000
            }
          }
        end

        run_test!
      end

      response "404", "payslip not found" do
        let(:payslip_id) { SecureRandom.uuid }

        let(:payslip_item) do
          {
            payslip_item: {
              item_type: "earning",
              code: "BONUS",
              amount: 15_000
            }
          }
        end

        run_test!
      end
    end
  end
end