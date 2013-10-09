require 'active_record'
require 'active_support'

module CacheableDelegator
  extend ActiveSupport::Concern

  included do 
    class_attribute :cached_class
  end

  module ClassMethods
    def cache_and_delegate(klass)
      raise ArgumentError, "Must pass in a class, not a #{klass}" unless klass.is_a?(Class)
      self.cached_class = klass

      belongs_to :source_record, class_name: self.cached_class.to_s
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

