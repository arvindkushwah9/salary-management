require "rails_helper"

RSpec.describe SalaryRecord, type: :model do
  subject(:salary_record) { build(:salary_record) }

  describe "associations" do
    it { is_expected.to belong_to(:employee) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:amount) }

    it do
      is_expected.to validate_numericality_of(:amount)
        .is_greater_than_or_equal_to(0)
    end

    it { is_expected.to validate_presence_of(:currency) }

    it do
      is_expected.to validate_length_of(:currency)
        .is_equal_to(3)
    end

    it { is_expected.to validate_presence_of(:effective_date) }
  end

  describe "scopes" do
    describe ".for_currency" do
      it "filters salary records by currency" do
        usd_salary = create(
          :salary_record,
          currency: "USD"
        )

        create(
          :salary_record,
          currency: "INR"
        )

        expect(described_class.for_currency("USD"))
          .to contain_exactly(usd_salary)
      end
    end

    describe ".effective_on_or_before" do
      it "returns records effective on or before the given date" do
        employee = create(:employee)

        applicable = create(
          :salary_record,
          employee: employee,
          effective_date: Date.new(2026, 1, 1)
        )

        create(
          :salary_record,
          employee: employee,
          effective_date: Date.new(2027, 1, 1)
        )

        expect(
          described_class.effective_on_or_before(Date.new(2026, 12, 31))
        ).to contain_exactly(applicable)
      end
    end

    describe ".chronological" do
      it "orders salary records from oldest to newest" do
        employee = create(:employee)

        older = create(
          :salary_record,
          employee: employee,
          effective_date: Date.new(2025, 1, 1)
        )

        newer = create(
          :salary_record,
          employee: employee,
          effective_date: Date.new(2026, 1, 1)
        )

        expect(described_class.chronological)
          .to eq([older, newer])
      end
    end

    describe ".latest_first" do
      it "orders salary records from newest to oldest" do
        employee = create(:employee)

        older = create(
          :salary_record,
          employee: employee,
          effective_date: Date.new(2025, 1, 1)
        )

        newer = create(
          :salary_record,
          employee: employee,
          effective_date: Date.new(2026, 1, 1)
        )

        expect(described_class.latest_first)
          .to eq([newer, older])
      end
    end
  end
end