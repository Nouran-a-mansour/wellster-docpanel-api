FactoryBot.define do
  factory :indication do
    sequence(:name) { |n| "Indication #{n}" }
  end
end