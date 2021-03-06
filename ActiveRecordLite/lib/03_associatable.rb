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
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    @name = name
    @class_name = options[:class_name] || @name.camelcase
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || (@name.camelcase.underscore + "_id").to_sym

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    @self_class_name = self_class_name

    @class_name = options[:class_name] || @name[0..-2].camelcase
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || (@self_class_name.camelcase.underscore + "_id").to_sym

  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
