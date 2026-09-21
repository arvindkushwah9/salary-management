require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject(:user) { build(:user) }

    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "requires an email" do
      user.email = nil

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "requires a password" do
      user.password = nil

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "requires a valid email format" do
      user.email = "invalid-email"

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "requires a supported role" do
      user.role = "admin"

      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("is not included in the list")
    end

    it "does not allow duplicate emails" do
      create(:user, email: "hr@example.com")

      duplicate = build(:user, email: "hr@example.com")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "normalizes email to lowercase" do
      user = create(
        :user,
        email: "  HR@EXAMPLE.COM  "
      )

      expect(user.email).to eq("hr@example.com")
    end
  end

  describe "password authentication" do
    it "authenticates with the correct password" do
      user = create(
        :user,
        password: "Password123!"
      )

      expect(user.authenticate("Password123!")).to eq(user)
    end

    it "rejects an incorrect password" do
      user = create(
        :user,
        password: "Password123!"
      )

      expect(user.authenticate("WrongPassword!")).to be_falsey
    end
  end
end