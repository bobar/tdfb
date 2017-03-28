class Clope < ActiveRecord::Base
  def sell(account, quantity, admin: nil)
    transaction do
      update(quantite: quantite + quantity)
      Transaction.log(account, Account.default_bank, quantity * euro_price, comment: "#{marque} (#{quantity})", admin: admin)
    end
  end

  def euro_price
    prix / 100.0
  end
end
