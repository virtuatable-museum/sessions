RSpec.configure do |config|
  config.after(:suite) do
    DatabaseCleaner.clean
  end
end