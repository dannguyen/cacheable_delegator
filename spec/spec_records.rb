module SpecBootstrap
  def reload_records!
    load(__FILE__)
  end
end
include SpecBootstrap


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)
ActiveRecord::Schema.define do


  drop_table :my_records if ActiveRecord::Base.connection.table_exists?(:my_records)
   
  create_table :my_records, force: true do |t|
    t.integer :awesome_value
    t.string  :name
    t.string  :address, limit: 42
    t.boolean :question
  end

  drop_table :my_cached_records if ActiveRecord::Base.connection.table_exists?(:my_cached_records)
  create_table :my_cached_records, force: true do |t|  
    t.string  :foo
    t.integer :foo_double_awesome_value
    t.integer :source_record_id
    t.string  :source_record_type
  end
end


class MyRecord < ActiveRecord::Base
  def foo
    "This is foo"
  end

  def foo_double_awesome_value
    awesome_value * 2
  end
end
MyRecord.reset_column_information


class MyCachedRecord < ActiveRecord::Base
  include CacheableDelegator
  cache_and_delegate MyRecord
end
MyCachedRecord.reset_column_information

