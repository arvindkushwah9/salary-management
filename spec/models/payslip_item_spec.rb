require "rails_helper"

RSpec.describe PayslipItem, type: :model do
  subject(:payslip_item) { build(:payslip_item) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(payslip_item).to be_valid
    end

    it "requires item_type" do
      payslip_item.item_type = nil

      expect(payslip_item).not_to be_valid
    end

    it "requires a valid item_type" do
      payslip_item.item_type = "invalid"

      expect(payslip_item).not_to be_valid
    end

    it "accepts supported item types" do
      PayslipItem::ITEM_TYPES.each do |item_type|
        payslip_item.item_type = item_type

        expect(payslip_item).to be_valid
      end
    end

    it "requires code" do
      payslip_item.code = nil

      expect(payslip_item).not_to be_valid
    end

    it "does not allow code longer than 30 characters" do
      payslip_item.code = "A" * 31

      expect(payslip_item).not_to be_valid
    end

    it "does not allow description longer than 100 characters" do
      payslip_item.description = "A" * 101

      expect(payslip_item).not_to be_valid
    end

    it "requires amount" do
      payslip_item.amount = nil

      expect(payslip_item).not_to be_valid
    end

    it "does not allow negative amount" do
      payslip_item.amount = -1

      expect(payslip_item).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to payslip" do
      association = described_class.reflect_on_association(:payslip)

      expect(association.macro).to eq(:belongs_to)
    end
  end
end