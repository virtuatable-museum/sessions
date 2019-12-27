FactoryBot.define do
  factory :empty_account, class: Arkaan::Account do
    factory :account do
      username { 'Babausse' }
      password { 'password' }
      password_confirmation { 'password' }
      email { 'test@test.com' }
      lastname { 'Courtois' }
      firstname { 'Vincent' }
    end
  end
end