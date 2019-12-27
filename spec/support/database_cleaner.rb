RSpec.configure do |config|
  config.after(:suite) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end