FactoryBot.define do
  factory :empty_application, class: Arkaan::OAuth::Application do
    factory :application do
      name { 'Other app' }
      key { 'other_key' }
      premium { false }
    end
    factory :premium_application do
      name { 'Test app' }
      key { 'test_key' }
      premium { true }
    end
  end
end