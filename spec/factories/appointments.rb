FactoryBot.define do
  factory :appointment do
    association :patient
    association :doctor
    scheduled_at { 1.week.from_now }
  end
end