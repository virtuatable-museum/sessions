FactoryGirl.define do
  factory :empty_service, class: Arkaan::Monitoring::Service do
    factory :service do
      key 'sessions'
      path '/sessions'
      diagnostic '/status'
    end
  end
end