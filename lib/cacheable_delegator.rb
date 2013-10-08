require 'active_record'
require 'active_support'

module CacheableDelegator
  extend ActiveSupport::Concern
  included do 
    class_attribute :cache_class
  end

  module ClassMethods
    def cache_and_delegate(klass)
      raise ArgumentError, "Must pass in a class, not a #{klass}" unless klass.is_a?(Class)
      self.cache_class = klass
    end
  end

end

