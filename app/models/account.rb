class Account < ActiveRecord::Base
  has_many :paid_transactions, class_name: :Transaction, foreign_key: :payer_id
  has_many :received_transactions, class_name: :Transaction, foreign_key: :receiver_id

  MANOU_FRANKIZ_ID = 12_368

  def self.search(term)
    where(trigramme: term) + where('LOWER(name) LIKE ?', "%#{term.downcase}%")
  end

  def age
    today = Date.current
    age = today.year - birthdate.year
    age -= 1 if today.month > birthdate.month
    age -= 1 if today.month == birthdate.month && today.day >= birthdate.day
    age
  end
end
