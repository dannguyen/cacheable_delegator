require 'active_record'
require 'active_support'
require 'active_record_inline_schema'

module CacheableDelegator
  extend ActiveSupport::Concern

  EXCLUDED_FIELDS = [:id, :cache_created_at, :cache_updated_at, :source_record_id, :source_record_type]
  COL_ATTRIBUTES_TO_UPGRADE = [:limit, :name, :null, :precision, :scale, :sql_type, :type]

  included do 
    class_attribute :source_class
    class_attribute :_custom_columns
  end

  module ClassMethods

    # this method defines the relation to an existing ActiveModel
    # it does not change the schema unless invoked with the bang!
    def cache_and_delegate(klass, opts={}, &blk)
      raise ArgumentError, "Must pass in a class, not a #{klass}" unless klass.is_a?(Class)
      self.source_class = klass
      belongs_to :source_record, class_name: self.source_class.to_s      

      # This is why you have to define custom columns in the given block
      # or after the call to cache and delegate

      reset_custom_columns!
      if block_given?
        yield self
      end


      self.source_class
    end


    # also runs upgrade_schema!
    def cache_and_delegate!(*args)
      cache_and_delegate(*args)

      upgrade_schema!
    end


    # assumes @@source_class has been set
    # 
    # will call ActiveRecord::Base.serialize based on parameters passed in
    # from 
    def upgrade_schema!
      # first we create a hash of source_columns
      source_column_hash = source_columns.inject({}) do |shash, source_col|
        source_col_atts = COL_ATTRIBUTES_TO_UPGRADE.inject({}){|hsh, att| hsh[att.to_sym] = source_col.send att; hsh  }
        shash[source_col.name] = source_col_atts

        shash
      end

      # then we merge it with custom_columns
      columns_to_add = source_column_hash.merge(custom_columns)


      # then we add them all in using .col method from active_record_inline_schema
      columns_to_add.each_pair do |col_name, col_atts|
        is_serialize = col_atts.delete(:serialize)
        col col_name, col_atts

        # by default, the client passes in serialize: true for plain serialization
        #  and has the option to pass in serialize: Hash
        if is_serialize
          serialize_klass = (is_serialize == true) ? Object : is_serialize
          serialize col_name, serialize_klass
        end
      end

      self.auto_upgrade!( :gentle => true )
    end


##################### source conveniences


    def source_columns
      source_class.columns.reject{|c| EXCLUDED_FIELDS.any?{|f| f.to_s == c.name }}
    end

    def source_reflections
      source_class.reflections
    end

    # value columns are just columns that aren't in EXCLUDED_FIELDS
    def value_column_names
      self.column_names - EXCLUDED_FIELDS.map{|f| f.to_s}
    end
  
###### column adding

    # Note: This must occur either during the .cache_and_delegate call
    #   or after it. 
    #   .cache_and_delegate *will* empty out custom_columns
    # And implicitly, @@source_class has already been defined at this point
    #   By default, raise an error if the column_name does not correspond
    #    to an instance_method of @@source_class, unless the :bespoke option
    #    is true
    #
    # opts: Hash of standard ActiveRecord::ConnectionAdapters::Column options
    #       and several custom opts:
    #         :bespoke => if true, then create this column on CachedRecord even
    #               if its source_class does not have method_defined?(column_name)
    #         :serialize => this is passed along to upgrade_schema!
    #               which will then serialize the column via ActiveRecord.serialize
    def add_custom_column(col_name, opts={})
      col_str = col_name.to_s
      is_bespoke = opts.delete :bespoke     
      if !self.source_class.method_defined?(col_str) && is_bespoke != true
        raise ArgumentError, "Since :bespoke != true, #{self.source_class} was expected to respond_to? :#{col_str}"
      end

      custom_columns[col_name.to_s] = opts
    end

    def custom_columns
      self._custom_columns ||= {}
    end

    def reset_custom_columns!
      self._custom_columns = {}
    end

  end




  DELEGATING_REGEX = /^delegate_(\w+)/

  def method_missing(foo, *args, &block)
    if foomatch = foo.to_s.match(DELEGATING_REGEX)
      foo = foomatch[1].to_s
      self.source_record.send(foo, *args, &block)
    elsif source_record.respond_to?(foo)
      source_record.send(foo, *args, &block)
    else
      super
    end
  end

  def respond_to?(meth, x=false)
    if meth.match(DELEGATING_REGEX)
      true
    elsif source_record.respond_to?(meth)
      true
    else
      super
    end
  end


  ################### Builder methods
  module ClassMethods
    def build_cache(source_obj)
      att_hsh = self.value_column_names.inject({}) do |hsh, cname|
        hsh[cname] = source_obj.send cname
        hsh
      end

      obj = self.new(att_hsh)
      obj.source_record = source_obj

      obj
    end

    def create_cache(obj)
      c = build_cache(obj)
      c.save 

      c
    end
  end

end

