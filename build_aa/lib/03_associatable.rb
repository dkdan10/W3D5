require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    Object.const_get(self.class_name)
  end

  def table_name
    # ...
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    self.primary_key = options[:primary_key]
    self.foreign_key = options[:foreign_key]
    self.class_name  = options[:class_name]
    self.primary_key ||= :id  
    self.foreign_key ||= (name.to_s + "_id").to_sym  
    self.class_name ||= name.capitalize  
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    self.primary_key = options[:primary_key]
    self.foreign_key = options[:foreign_key] 
    self.class_name  = options[:class_name]
    self.primary_key ||= :id  
    self.foreign_key ||= (self_class_name.downcase.to_s + "_id").to_sym  
    self.class_name ||= name.to_s.singularize.capitalize  
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)
    define_method(options.class_name.downcase) do
      options.model_class.where(:id => "#{self.send(options.foreign_key)}").first
    end
  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, self.name, options)
    define_method(options.class_name.downcase + "s") do
      # debugger
      options.model_class.where(options.foreign_key => "#{self.send(options.primary_key)}")
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable 
end
