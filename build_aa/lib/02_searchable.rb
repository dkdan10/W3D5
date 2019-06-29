require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # p params
    # p self.columns
    # p self
  #   where_vals = self.columns.select{ |col|
  #     params.keys.include?(col)
  #   }.map { |s_col|
  #     "#{s_col} = '#{params[s_col.to_sym]}'" 
  # }.join(" AND ")
  where_vals = params.keys.map{|key| "#{key} = ?"}.join(" AND ")
    data = DBConnection.execute(<<-SQL, *params.values)
       SELECT
         *
       FROM
         #{self.table_name}
       WHERE
         #{where_vals}
    SQL
    data.map{|datum| self.new(datum)}
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
