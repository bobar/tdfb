class Transaction < ActiveRecord::Base
  belongs_to :buyer, class_name: :Account
  belongs_to :receiver, class_name: :Account
  belongs_to :administrator, class_name: :Account, foreign_key: :admin
  self.per_page = 50

  def self.log(account, bank, value, comment: nil, admin: nil, time: Time.current, is_tobacco: false)
    batch_log([[account, value]], bank, comment: comment, admin: admin, time: time, is_tobacco: is_tobacco)
  end

  # amounts is an array [ [account, value] ]
  def self.batch_log(amounts, bank,
                     comment: nil, admin: nil, time: Time.current, is_tobacco: false, bank_comment: false)
    comment ||= ''
    transaction do
      amounts.each do |account, value|
        buyer, receiver = value > 0 ? [account, bank] : [bank, account]
        amount = value.abs

        # We round the amount to the nearest cent upwards
        amount = (amount * 100).round(1).ceil

        buyer.balance -= amount
        buyer.turnover += amount
        buyer.total_clopes += amount if is_tobacco

        receiver.balance += amount
        receiver.total_clopes += amount if is_tobacco # So default bank has stats

        create(
          buyer_id: buyer.id, receiver_id: receiver.id, amount: amount, comment: comment, admin: admin.try(:id), date: time, is_tobacco: is_tobacco,
        )

        account.save
      end
      bank.nickname += "\nDébit fichier #{Time.current.strftime('%F %T')}: #{comment}" if bank_comment && !comment.empty?
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
    create(buyer_id: account.id, receiver_id: account.id, amount: 0, comment: comment, admin: admin.try(:id), date: Time.current)
  end

  def cancel(admin)
    self.class.transaction do
      buyer.balance += amount
      buyer.turnover -= amount
      buyer.total_clopes -= amount if is_tobacco

      receiver.balance -= amount
      receiver.total_clopes -= amount if is_tobacco

      new_comment = comment || ''
      new_comment += ' ' unless new_comment.empty?
      new_comment += if admin
                       I18n.t(:transaction_cancelled_admin, amount: amount / 100.0, admin: admin.account.trigramme)
                     else
                       I18n.t(:transaction_cancelled_comment, amount: amount / 100.0)
                     end

      update(amount: 0, comment: new_comment)

      buyer.save
      receiver.save
    end
  end
end
