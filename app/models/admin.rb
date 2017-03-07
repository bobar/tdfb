class Admin < ActiveRecord::Base
  belongs_to :account, foreign_key: :id
end
