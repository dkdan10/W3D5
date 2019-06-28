require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
        --cats
      LIMIT
        0
    SQL
    @columns.first.map(&:to_sym)
  end

  def self.finalize!
    cols = self.columns
    cols.each do |col|
      define_method(col) do 
        self.attributes[col]
      end
      define_method("#{col}=") do |val|
        self.attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name ||= table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.tableize
  end

  def self.all
    # ...
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(all)
  end

  def self.parse_all(results)
    # ...
    results.map{|options| self.new(options)}
  end

  def self.find(id)
    # ...
    found = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
        --cats
      WHERE
        id = ?
    SQL
    !found.empty? ? self.new(found.first) : nil
  end

  def initialize(params = {})
    # ...
    params.each do |key, value|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
      method = (key.to_s + "=").to_sym
      self.send(method, value)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    # ...
    @attributes.values
  end

  
  def insert
    # ...
    columns = self.class.columns.drop(1).join(', ')
    questions = (["?"] * self.class.columns.drop(1).length).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{columns})
      VALUES
        (#{questions})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    columns = self.class.columns.join(' = ?, ') + " = ?"
    
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{columns}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
