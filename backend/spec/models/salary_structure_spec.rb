require "rails_helper"

RSpec.describe SalaryStructure, type: :model do
  subject(:salary_structure) { build(:salary_structure) }

  describe "associations" do
    it { is_expected.to belong_to(:employee) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(salary_structure).to be_valid
    end

    it "requires base salary" do
      salary_structure.base_salary = nil

      expect(salary_structure).not_to be_valid
      expect(salary_structure.errors[:base_salary]).to include("can't be blank")
    end

    it "requires currency" do
      salary_structure.currency = nil

      expect(salary_structure).not_to be_valid
      expect(salary_structure.errors[:currency]).to include("can't be blank")
    end

    it "requires effective_from" do
      salary_structure.effective_from = nil

      expect(salary_structure).not_to be_valid
      expect(salary_structure.errors[:effective_from]).to include("can't be blank")
    end

    it "does not allow negative base salary" do
      salary_structure.base_salary = -1

      expect(salary_structure).not_to be_valid
    end

    it "does not allow effective_to before effective_from" do
      salary_structure.effective_from = Date.new(2026, 1, 1)
      salary_structure.effective_to = Date.new(2025, 12, 31)

      expect(salary_structure).not_to be_valid
      expect(salary_structure.errors[:effective_to]).to include(
        "must be on or after effective_from"
      )
    end
  end

  describe ".for_currency" do
    it "filters salary structures by currency" do
      usd_salary = create(
        :salary_structure,
        currency: "USD"
      )

      create(
        :salary_structure,
        currency: "EUR"
      )

      expect(
        described_class.for_currency("USD")
      ).to contain_exactly(usd_salary)
    end
  end

  describe ".effective_on_or_before" do
    it "returns structures effective on or before the given date" do
      employee = create(:employee)

      applicable = create(
        :salary_structure,
        employee: employee,
        effective_from: Date.new(2026, 1, 1)
      )

      create(
        :salary_structure,
        employee: employee,
        effective_from: Date.new(2027, 1, 1)
      )

      result = described_class.effective_on_or_before(
        Date.new(2026, 6, 1)
      )

      expect(result).to include(applicable)
    end
  end

  describe ".chronological" do
    it "orders salary structures from oldest to newest" do
      employee = create(:employee)

      older = create(
        :salary_structure,
        employee: employee,
        effective_from: Date.new(2025, 1, 1)
      )

      newer = create(
        :salary_structure,
        employee: employee,
        effective_from: Date.new(2026, 1, 1)
      )

      expect(
        described_class.chronological
      ).to eq([older, newer])
    end
  end

  describe ".latest_first" do
    it "orders salary structures from newest to oldest" do
      employee = create(:employee)

      older = create(
        :salary_structure,
        employee: employee,
        effective_from: Date.new(2025, 1, 1)
      )

      newer = create(
        :salary_structure,
        employee: employee,
        effective_from: Date.new(2026, 1, 1)
      )

      expect(
        described_class.latest_first
      ).to eq([newer, older])
    end
  end
end