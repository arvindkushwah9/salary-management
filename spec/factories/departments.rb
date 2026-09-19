FactoryBot.define do
  factory :department do
    sequence(:code) { |n| "DEP#{n}" }
    sequence(:name) { |n| "Department #{n}" }
  end
end