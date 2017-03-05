class Transaction < ActiveRecord::Base
  belongs_to :payer, class_name: :Account
  belongs_to :receiver, class_name: :Account
  belongs_to :admin, class_name: :Account
end
