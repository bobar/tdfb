class GroupLogController < ApplicationController
  def index
  end

  def log
    amount = params[:amount].to_f
    fail TdbException, 'Amount must be positive!' if amount < 0
    fail TdbException, 'Amount too high!' if amount > 200
    trigrammes = params[:trigramme].select { |t| t.size == 3 }.map(&:to_s).map(&:upcase)
    accounts = Account.where(trigramme: trigrammes)
    fail TdbExceptionm 'Need at least 1 account' if accounts.empty?
    require_admin!(:log_groupe)
    comment = params[:comment] + " (shared with #{trigrammes.join(', ')})"
    per_person = (10 * amount / accounts.size).ceil / 10.0
    time = Time.current
    accounts.each do |acc|
      Transaction.log(acc, @bank, per_person, comment: comment, admin: @admin, time: time)
    end
    redirect_to_trigramme(accounts.first.trigramme)
  end
end
