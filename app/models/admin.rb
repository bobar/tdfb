class Admin < ActiveRecord::Base
  belongs_to :account, foreign_key: :id
  has_one :right, primary_key: :permissions, foreign_key: :permissions
end
