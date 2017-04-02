class Transaction < ActiveRecord::Base
  belongs_to :buyer, class_name: :Account, foreign_key: :id
  belongs_to :receiver, class_name: :Account, foreign_key: :id2
  belongs_to :administrator, class_name: :Account, foreign_key: :admin
  self.per_page = 25

  def self.log(account, bank, amount, comment: nil, admin: nil, time: Time.current)
    comment ||= ''
    amount = (amount * 100).ceil # Screwing the customers
    transaction do
      account.balance = account.balance - amount
      account.turnover = account.turnover + amount if amount > 0
      bank.balance = bank.balance + amount
      bank.turnover = bank.turnover - amount if amount < 0
      create(id: account.id, id2: bank.id, price: -amount, comment: comment, admin: admin.try(:id), date: time)
      create(id: bank.id, id2: account.id, price: amount, comment: comment, admin: admin.try(:id), date: time)
      account.save
      bank.save
    end
  end

  def self.account_update(account, updated = {}, admin: nil)
    updates = updated.map do |k, v|
      next if v == account.__send__(k)
      detail = "new #{k}"
      detail += " (#{account.__send__(k)} => #{v})" unless [:nickname, :picture].include? k.to_sym
      detail
    end.compact
    return if updates.empty?
    comment = 'Account updated: ' + updates.join(', ')
    create(id: account.id, id2: account.id, price: 0, comment: comment, admin: admin.try(:id), date: Time.current)
  end

  def cancel(reverse, admin) # Reverse is the opposite transaction
    payer = Account.find_by(id: id)
    self.class.transaction do
      payer.balance -= price
      payer.turnover += price if price < 0

      receiver.balance += price
      receiver.turnover -= price if price > 0

      new_comment = comment || ''
      new_comment += ' ' unless new_comment.empty?
      new_comment += if admin
                       I18n.t(:transaction_cancelled_admin, amount: price / 100.0, admin: admin.account.trigramme)
                     else
                       I18n.t(:transaction_cancelled_comment, amount: price / 100.0)
                     end
      self.class.where(date: date, id: id, id2: id2, price: price).update_all(
        "price = 0, comment = #{self.class.connection.quote(new_comment)}",
      )

      new_comment = reverse.comment || ''
      new_comment += ' ' unless new_comment.empty?
      new_comment += if admin
                       I18n.t(:transaction_cancelled_admin, amount: -price / 100.0, admin: admin.account.trigramme)
                     else
                       I18n.t(:transaction_cancelled_comment, amount: -price / 100.0)
                     end
      self.class.where(date: date, id: id2, id2: id, price: -price).update_all(
        "price = 0, comment = #{self.class.connection.quote(new_comment)}",
      )

      payer.save
      receiver.save
    end
  end
end
