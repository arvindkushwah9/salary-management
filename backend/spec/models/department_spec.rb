require "rails_helper"

RSpec.describe Department, type: :model do
  subject(:department) { build(:department) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(department).to be_valid
    end

    it "requires a code" do
      department.code = nil

      expect(department).not_to be_valid
      expect(department.errors[:code]).to include("can't be blank")
    end

    it "requires a name" do
      department.name = nil

      expect(department).not_to be_valid
      expect(department.errors[:name]).to include("can't be blank")
    end

    it "requires a unique code" do
      create(:department, code: "ENG")

      department.code = "ENG"

      expect(department).not_to be_valid
    end

    it "requires a unique name" do
      create(:department, name: "Engineering")

      department.name = "Engineering"

      expect(department).not_to be_valid
    end
  end

  describe "associations" do
    it "has many employees" do
      association = described_class.reflect_on_association(:employees)

      expect(association.macro).to eq(:has_many)
    end
  end

  describe "normalization" do
    it "normalizes code to uppercase" do
      department.code = " eng "

      department.valid?

      expect(department.code).to eq("ENG")
    end

    it "strips whitespace from name" do
      department.name = " Engineering "

      department.valid?

      expect(department.name).to eq("Engineering")
    end
  end
end