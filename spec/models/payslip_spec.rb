require "rails_helper"

RSpec.describe Payslip, type: :model do
  subject(:payslip) { build(:payslip) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(payslip).to be_valid
    end

    it "requires working_days" do
      payslip.working_days = nil

      expect(payslip).not_to be_valid
    end

    it "requires working_days to be greater than zero" do
      payslip.working_days = 0

      expect(payslip).not_to be_valid
    end

    it "does not allow paid_days greater than working_days" do
      payslip = build(
        :payslip,
        employee: create(:employee),
        payroll_run: create(:payroll_run),
        working_days: 20,
        paid_days: 21
      )

      expect(payslip).not_to be_valid
      expect(payslip.errors[:paid_days]).to include(
        "cannot exceed working_days"
      )
    end

    it "allows paid_days equal to working_days" do
      payslip = build(
        :payslip,
        employee: create(:employee),
        payroll_run: create(:payroll_run),
        working_days: 20,
        paid_days: 20
      )

      expect(payslip).to be_valid
    end

    it "does not allow negative gross earnings" do
      payslip.gross_earnings = -1

      expect(payslip).not_to be_valid
    end

    it "does not allow negative deductions" do
      payslip.total_deductions = -1

      expect(payslip).not_to be_valid
    end

    it "does not allow negative net pay" do
      payslip.net_pay = -1

      expect(payslip).not_to be_valid
    end

    it "requires a valid payment status" do
      payslip.payment_status = "unknown"

      expect(payslip).not_to be_valid
    end

    it "accepts supported payment statuses" do
      Payslip::PAYMENT_STATUSES.each do |status|
        payslip.payment_status = status

        expect(payslip).to be_valid
      end
    end

    it "does not allow duplicate employee payslips in the same payroll run" do
      employee = create(:employee)
      payroll_run = create(:payroll_run)

      create(
        :payslip,
        employee: employee,
        payroll_run: payroll_run
      )

      duplicate_payslip = build(
        :payslip,
        employee: employee,
        payroll_run: payroll_run
      )

      expect(duplicate_payslip).not_to be_valid
      expect(duplicate_payslip.errors[:employee_id]).to include(
        "already has a payslip for this payroll run"
      )
    end
  end

  describe "associations" do
    it "belongs to payroll_run" do
      association = described_class.reflect_on_association(:payroll_run)

      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to employee" do
      association = described_class.reflect_on_association(:employee)

      expect(association.macro).to eq(:belongs_to)
    end

    it "has many payslip_items" do
      association = described_class.reflect_on_association(:payslip_items)

      expect(association.macro).to eq(:has_many)
    end
  end

  describe "#recalculate_totals!" do
    let(:payslip) do
      create(
        :payslip,
        gross_earnings: 120_000,
        total_deductions: 0,
        net_pay: 120_000
      )
    end

    it "calculates deductions and net pay from deduction items" do
      create(
        :payslip_item,
        payslip: payslip,
        item_type: "deduction",
        code: "PF",
        amount: 5_000
      )

      create(
        :payslip_item,
        payslip: payslip,
        item_type: "statutory",
        code: "TAX",
        amount: 10_000
      )

      payslip.recalculate_totals!

      expect(payslip.total_deductions).to eq(15_000)
      expect(payslip.net_pay).to eq(105_000)
    end
  end

  it "does not count earning items as deductions" do
    create(
      :payslip_item,
      payslip: payslip,
      item_type: "earning",
      code: "BONUS",
      amount: 10_000
    )

    payslip.recalculate_totals!

    expect(payslip.total_deductions).to eq(0)
    expect(payslip.net_pay).to eq(120_000)
  end
end