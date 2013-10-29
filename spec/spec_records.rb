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


  create_table :my_covers, force: true do |t|
    t.integer :my_record_id
    t.string  :subject
    t.integer :year, default: 1999
  end
end


class MyRecord < ActiveRecord::Base
  has_many :my_covers
  def foo
    "This is foo"
  end

  def foo_double_awesome_value
    awesome_value.to_i * 2
  end

  def my_record_special_foo
    'special foo'
  end

  def superfluous_instance_method
    'hello'
  end

  def foo_array
    [awesome_value, 'foo!', awesome_value]
  end



  DELEGATING_REGEX ||= /^dynamic_(\w+)/

  def method_missing(foo, *args, &block)
    if foomatch = foo.to_s.match(DELEGATING_REGEX)
      foo = foomatch[1].to_s
      self.send(foo, *args, &block)
    else
      super
    end
  end

  def respond_to?(method, f=false)
    method =~ DELEGATING_REGEX || super
  end


  def respond_to_missing?(method, *)
    method =~ DELEGATING_REGEX || super
  end
end

class MyCover < ActiveRecord::Base
  belongs_to :my_record
end


class MyCachedRecord < ActiveRecord::Base
  # for testing purposes
   self.serialized_attributes = {}

  include CacheableDelegator
  cache_and_delegate MyRecord
end
MyCachedRecord.reset_column_information

