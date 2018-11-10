require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    return @columns if @columns

    columns = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    symbols = columns.first.map(&:to_sym)
    @columns = symbols
  end

  def self.finalize!
    cols = self.columns

    cols.each do |col|
      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = self.to_s.downcase + "s"
    @table_name
  end

  def self.all
    all_info = DBConnection.execute(<<-SQL)
      Select *
      FROM #{self.table_name}
    SQL

    self.parse_all(all_info)
  end

  def self.parse_all(results)
    results.map { |instance| self.new(instance) }
  end

  def self.find(id)
    info = DBConnection.execute(<<-SQL, id)
      Select *
      FROM #{self.table_name}
      WHERE id = ?
      LIMIT 1
    SQL

    info = info.first

    if info
      return self.new(info)
    else
      return nil
    end
  end

  def initialize(params = {})

    params.each do |key, value|
      key_sym = key.to_sym

      if self.class.columns.include?(key_sym)
        self.send("#{key}=", value)
      else
        raise "unknown attribute '#{key}'"
      end

    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    cols = self.class.columns
    cols.map { |col| self.send(col)}
  end

  def insert
    cols = self.class.columns

    marks = []
    cols.length.times { marks << "?"}
    qs = marks.join(", ")

    cols = cols.join(", ")

    vals = attribute_values

    DBConnection.execute(<<-SQL, vals)
      INSERT INTO
        #{self.class.table_name} (#{cols})
      VALUES
        (#{qs});
    SQL

    self.send("id=", DBConnection.last_insert_row_id)
  end

  def update

    cols = self.class.columns
    cols = cols.map {|col| col.to_s + " = ?"}.join(", ")

    args = attribute_values

    DBConnection.execute(<<-SQL, args)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols}
      WHERE
        id = #{self.id}
    SQL

  end

  def save

    if self.id
      self.update
    else
      self.insert
    end

  end
end
