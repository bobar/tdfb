class Right < ActiveRecord::Base
  self.table_name = :droits

  def self.right_columns
    Right.columns.map(&:name) - %w(permissions nom)
  end
end
