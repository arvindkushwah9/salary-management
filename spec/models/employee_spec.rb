require "rails_helper"

RSpec.describe Employee, type: :model do
  subject(:employee) { build(:employee) }

  describe "associations" do
    it { is_expected.to have_many(:salary_records).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:employee_number) }
    it { is_expected.to validate_uniqueness_of(:employee_number) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:employment_status) }

    it { is_expected.to validate_uniqueness_of(:email) }

    it do
      is_expected.to(
        allow_value("employee@example.com").for(:email)
      )
    end

    it do
      is_expected.not_to(
        allow_value("invalid-email").for(:email)
      )
    end
  end

  describe "scopes" do
    describe ".active" do
      it "returns active employees" do
        active_employee = create(:employee, employment_status: "active")
        create(:employee, employment_status: "inactive")

        expect(described_class.active).to contain_exactly(active_employee)
      end
    end

    describe ".inactive" do
      it "returns inactive employees" do
        inactive_employee = create(:employee, employment_status: "inactive")
        create(:employee, employment_status: "active")

        expect(described_class.inactive).to contain_exactly(inactive_employee)
      end
    end

    describe ".by_country" do
      it "filters employees by country" do
        us_employee = create(:employee, country: "US")
        create(:employee, country: "IN")

        expect(described_class.by_country("US"))
          .to contain_exactly(us_employee)
      end

      it "returns all employees when country is blank" do
        employees = create_list(:employee, 2)

        expect(described_class.by_country(nil))
          .to contain_exactly(*employees)
      end
    end

    describe ".by_department" do
      it "filters employees by department" do
        engineer = create(:employee, department: "Engineering")
        create(:employee, department: "Finance")

        expect(described_class.by_department("Engineering"))
          .to contain_exactly(engineer)
      end
    end

    describe ".search" do
      it "searches by employee number" do
        employee = create(
          :employee,
          employee_number: "EMP-12345"
        )

        expect(described_class.search("EMP-12345"))
          .to contain_exactly(employee)
      end

      it "searches by name" do
        employee = create(
          :employee,
          first_name: "Arvind",
          last_name: "Kushwah"
        )

        expect(described_class.search("Arvind"))
          .to contain_exactly(employee)

        expect(described_class.search("Kushwah"))
          .to contain_exactly(employee)
      end

      it "searches by email" do
        employee = create(
          :employee,
          email: "arvind@example.com"
        )

        expect(described_class.search("arvind@example.com"))
          .to contain_exactly(employee)
      end

      it "returns all employees when search term is blank" do
        employees = create_list(:employee, 2)

        expect(described_class.search(nil))
          .to contain_exactly(*employees)
      end
    end
  end

  describe "#full_name" do
    it "returns the employee's full name" do
      employee = build(
        :employee,
        first_name: "Arvind",
        last_name: "Kushwah"
      )

      expect(employee.full_name).to eq("Arvind Kushwah")
    end
  end

  describe "#current_salary" do
    it "returns the latest effective salary" do
      employee = create(:employee)

      older = create(
        :salary_record,
        employee: employee,
        effective_date: 2.months.ago.to_date,
        amount: 80_000
      )

      latest = create(
        :salary_record,
        employee: employee,
        effective_date: 1.month.ago.to_date,
        amount: 90_000
      )

      expect(employee.current_salary).to eq(latest)
      expect(employee.current_salary).not_to eq(older)
    end

    it "does not return a future salary" do
      employee = create(:employee)

      future_salary = create(
        :salary_record,
        employee: employee,
        effective_date: 1.month.from_now.to_date
      )

      expect(employee.current_salary).to be_nil
      expect(employee.current_salary).not_to eq(future_salary)
    end
  end
end