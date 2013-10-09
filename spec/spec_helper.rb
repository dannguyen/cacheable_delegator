# Configure Rails Envinronment

require 'cacheable_delegator'
require 'pry'

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)
ActiveRecord::Migration.verbose = false



ActiveRecord::Schema.define do
  create_table :my_records do |t|
    t.integer :values
  end
  create_table :my_cached_records do |t|  
    t.string  :foo
    t.integer :double_values
    t.integer :source_record_id
    t.string  :source_record_type
  end
end


class MyRecord < ActiveRecord::Base

  def foo
    "This is foo"
  end

  def double_values
    values * 2
  end

end


class MyCachedRecord < ActiveRecord::Base
  include CacheableDelegator
  cache_and_delegate MyRecord
end



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

