FactoryGirl.define do
  factory :empty_session, class: Arkaan::Authentication::Session do
    factory :session do
      token 'session_token'
    end
  end
end