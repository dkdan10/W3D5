require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    p where_vals = self.columns.select{ |col|
      params.keys.include?(col)
    }.map { |s_col|

      "#{s_col} = '#{params[s_col.to_sym]}'" 
  }.join(" AND ")
    data = DBConnection.execute(<<-SQL)
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
