require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    where_line = params.keys.map {|key| key.to_s + " = ?"}
    where_line = where_line.join(" AND ")

    vals = params.values

    findings = DBConnection.execute(<<-SQL, vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    self.parse_all(findings)
  end
end

class SQLObject
  extend Searchable
end
