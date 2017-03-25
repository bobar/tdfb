class Transaction < ActiveRecord::Base
  belongs_to :payer, class_name: :Account, foreign_key: :id
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
      next if v == account[k]
      detail = "new #{k}"
      detail += " (#{account.__send__(k)} => #{v})" unless k.to_sym == :nickname
      detail
    end.compact
    return if updates.empty?
    comment = 'Account updated: ' + updates.join(', ')
    create(id: account.id, id2: account.id, price: 0, comment: comment, admin: admin.try(:id), date: Time.current)
  end
end
