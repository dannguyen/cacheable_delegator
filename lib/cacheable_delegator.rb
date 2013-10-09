require 'active_record'
require 'active_support'
require 'active_record_inline_schema'

module CacheableDelegator
  extend ActiveSupport::Concern

  EXCLUDED_FIELDS = [:id, :cache_created_at, :cache_updated_at]
  COL_ATTRIBUTES_TO_UPGRADE = [:limit, :name, :null, :precision, :scale, :sql_type, :type]

  included do 
    class_attribute :source_class
  end

  module ClassMethods

    def build_cache(obj)

    end

    def create_cache(obj)

    end




    def cache_and_delegate(klass, opts={}, &blk)
      raise ArgumentError, "Must pass in a class, not a #{klass}" unless klass.is_a?(Class)
      self.source_class = klass
      belongs_to :source_record, class_name: self.source_class.to_s      

      self.source_class
    end


    # assumes @@source_class has been set
    def upgrade_schema!
      source_columns = self.source_class.columns.reject{|c| EXCLUDED_FIELDS.any?{|f| f.to_s == c.name }}

      source_columns.each do |source_col|
        source_col_atts = COL_ATTRIBUTES_TO_UPGRADE.inject({}){|hsh, att| hsh[att.to_sym] = source_col.send att; hsh  }

        col source_col.name, source_col_atts
      end

      self.auto_upgrade!( :gentle => true )
    end
  end


  DELEGATING_REGEX = /^delegate_(\w+)/


  def method_missing(foo, *args, &block)
    if foomatch = foo.to_s.match(DELEGATING_REGEX)
      foo = foomatch[1].to_s
      
      self.source_record.send(foo, *args, &block)
    else
      super
    end
  end

  def respond_to?(meth, x=false)
    if meth.match(DELEGATING_REGEX)
      true
    else
      super
    end
  end

end

