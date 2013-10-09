# Configure Rails Envinronment

require 'cacheable_delegator'
require 'pry'

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation


ActiveRecord::Migration.verbose = false

require 'spec_records'


RSpec.configure do |config|

  config.filter_run_excluding skip: true 
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true

  config.mock_with :rspec

   # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

