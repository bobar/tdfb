class Transaction < ActiveRecord::Base
  belongs_to :payer, class_name: :Account, foreign_key: :id
  belongs_to :receiver, class_name: :Account, foreign_key: :id2
  belongs_to :admin, class_name: :Account, foreign_key: :admin

  def self.log(account, bank, amount, comment: '', admin: nil)
    ActiveRecord::Base.Transaction do
      account.balance = account.balance - amount
      account.turnover = account.turnover + amount if amount > 0
      bank.balance = bank.balance + amount
      bank.turnover = bank.turnover - amount if amount < 0
      Transaction.create(id: account.id, id2: bank.id, price: amount, comment: comment, admin: admin.id)
      Transaction.create(id: bank.id, id2: account.id, price: -amount, comment: comment, admin: admin.id)
      account.save
      bank.save
    end
  end
end
