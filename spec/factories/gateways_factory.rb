FactoryBot.define do
  factory :empty_gateway, class: Arkaan::Monitoring::Gateway do
    factory :gateway do
      url { 'https://gateway.test.com' }
      token { 'test_token' }
    end
  end
end