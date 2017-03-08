class Clope < ActiveRecord::Base
  def sell(account, quantity, admin: nil)
    transaction do
      update(quantite: quantite + quantity)
      Transaction.log(account, Account.default_bank, quantity * prix / 100.0, comment: "#{marque} (#{quantity})", admin: admin)
    end
  end
end
