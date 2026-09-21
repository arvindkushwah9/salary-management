require "rails_helper"

RSpec.describe Payroll::ProcessService do
  describe "#call" do
    let(:payroll_run) do
      create(
        :payroll_run,
        payroll_period: "2026-09",
        status: "draft"
      )
    end

    let(:employee) do
      create(
        :employee,
        status: "active"
      )
    end

    let!(:salary_structure) do
      create(
        :salary_structure,
        employee: employee,
        base_salary: 100_000,
        housing_allowance: 10_000,
        conveyance_allowance: 5_000,
        special_allowance: 5_000,
        currency: "USD",
        effective_from: Date.new(2026, 1, 1),
        effective_to: nil
      )
    end

    subject(:process_payroll) do
      described_class.new(payroll_run).call
    end

    it "processes the payroll run" do
      expect {
        process_payroll
      }.to change(Payslip, :count).by(1)
    end

    it "creates a payslip for the active employee" do
      process_payroll

      payslip = payroll_run.payslips.find_by(employee: employee)

      expect(payslip).to be_present
      expect(payslip.gross_earnings).to eq(120_000)
      expect(payslip.total_deductions).to eq(0)
      expect(payslip.net_pay).to eq(120_000)
    end

    it "creates the expected earning items" do
      process_payroll

      payslip = payroll_run.payslips.find_by(employee: employee)

      expect(
        payslip.payslip_items.pluck(:code, :item_type)
      ).to contain_exactly(
        ["BASIC", "earning"],
        ["HRA", "earning"],
        ["CONVEYANCE", "earning"],
        ["SPECIAL", "earning"]
      )
    end

    it "creates earning items with the salary structure amounts" do
      process_payroll

      payslip = payroll_run.payslips.find_by(employee: employee)

      items = payslip.payslip_items.index_by(&:code)

      expect(items["BASIC"].amount).to eq(100_000)
      expect(items["HRA"].amount).to eq(10_000)
      expect(items["CONVEYANCE"].amount).to eq(5_000)
      expect(items["SPECIAL"].amount).to eq(5_000)
    end

    it "updates payroll totals" do
      process_payroll

      payroll_run.reload

      expect(payroll_run.total_gross).to eq(120_000)
      expect(payroll_run.total_deductions).to eq(0)
      expect(payroll_run.total_net).to eq(120_000)
    end

    it "processes multiple active employees" do
      second_employee = create(
        :employee,
        status: "active"
      )

      create(
        :salary_structure,
        employee: second_employee,
        base_salary: 80_000,
        housing_allowance: 8_000,
        conveyance_allowance: 4_000,
        special_allowance: 3_000,
        currency: "USD",
        effective_from: Date.new(2026, 1, 1)
      )

      expect {
        process_payroll
      }.to change(Payslip, :count).by(2)

      payroll_run.reload

      expect(payroll_run.total_gross).to eq(215_000)
      expect(payroll_run.total_deductions).to eq(0)
      expect(payroll_run.total_net).to eq(215_000)
    end

    it "does not process terminated employees" do
      terminated_employee = create(
        :employee,
        status: "terminated"
      )

      create(
        :salary_structure,
        employee: terminated_employee,
        base_salary: 100_000,
        housing_allowance: 10_000,
        conveyance_allowance: 5_000,
        special_allowance: 5_000,
        currency: "USD",
        effective_from: Date.new(2026, 1, 1)
      )

      process_payroll

      expect(
        payroll_run.payslips.exists?(employee: terminated_employee)
      ).to be(false)
    end

    it "does not process employees without a current salary structure" do
      employee_without_salary = create(
        :employee,
        status: "active"
      )

      process_payroll

      expect(
        payroll_run.payslips.exists?(employee: employee_without_salary)
      ).to be(false)
    end

    it "uses the current salary structure" do
      create(
        :salary_structure,
        employee: employee,
        base_salary: 90_000,
        housing_allowance: 9_000,
        conveyance_allowance: 4_000,
        special_allowance: 2_000,
        currency: "USD",
        effective_from: Date.new(2025, 1, 1),
        effective_to: Date.new(2025, 12, 31)
      )

      process_payroll

      payslip = payroll_run.payslips.find_by(employee: employee)

      expect(payslip.gross_earnings).to eq(120_000)
    end

    it "sets the payroll run status to approved after successful processing" do
      process_payroll

      expect(payroll_run.reload.status).to eq("approved")
    end

    it "rejects a payroll run that is not in draft status" do
      payroll_run.update!(status: "approved")

      expect {
        process_payroll
      }.to raise_error(
        ArgumentError,
        "Only draft payroll runs can be processed"
      )
    end

    it "rejects a payroll run that is already processing" do
      payroll_run.update!(status: "processing")

      expect {
        process_payroll
      }.to raise_error(
        ArgumentError,
        "Only draft payroll runs can be processed"
      )
    end

    it "does not process an approved payroll run" do
      payroll_run.update!(status: "approved")

      expect {
        process_payroll
      }.to raise_error(
        ArgumentError,
        "Only draft payroll runs can be processed"
      )

      expect(payroll_run.payslips).to be_empty
    end

    it "rolls back the payroll when processing fails" do
      allow_any_instance_of(Employee).to receive(:current_salary)
        .and_raise(StandardError, "salary calculation failed")

      expect {
        process_payroll
      }.to raise_error(
        StandardError,
        "salary calculation failed"
      )

      expect(Payslip.count).to eq(0)
      expect(PayslipItem.count).to eq(0)

      payroll_run.reload

      expect(payroll_run.status).to eq("draft")
      expect(payroll_run.total_gross).to eq(0)
      expect(payroll_run.total_deductions).to eq(0)
      expect(payroll_run.total_net).to eq(0)
    end

    it "does not use an expired salary structure" do
  expired_employee = create(
    :employee,
    status: "active"
  )

  create(
    :salary_structure,
    employee: expired_employee,
    base_salary: 100_000,
    housing_allowance: 10_000,
    conveyance_allowance: 5_000,
    special_allowance: 5_000,
    currency: "USD",
    effective_from: Date.new(2026, 1, 1),
    effective_to: Date.new(2026, 8, 31)
  )

  expect(expired_employee.salary_structures.count).to eq(1)
  expect(expired_employee.current_salary).to be_nil

  payroll_run = create(
    :payroll_run,
    payroll_period: "2026-09",
    status: "draft"
  )

  described_class.new(payroll_run).call

  expect(
    payroll_run.payslips.exists?(employee: expired_employee)
  ).to be(false)
end

    it "does not use a future salary structure" do
      salary_structure.update!(
        effective_from: Date.current + 1.day,
        effective_to: nil
      )

      expect(employee.current_salary).to be_nil

      process_payroll

      expect(
        payroll_run.payslips.exists?(employee: employee)
      ).to be(false)
    end

    it "does not process employees who are not active" do
      employee.update!(status: "on_leave")

      process_payroll

      expect(
        payroll_run.payslips.exists?(employee: employee)
      ).to be(false)
    end
  end
end