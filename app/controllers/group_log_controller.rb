class GroupLogController < ApplicationController
  def index
  end

  def log
    amount = params[:amount].to_f
    fail TdbException, I18n.t('exception.need_positive_amount') if amount < 0
    fail TdbException, I18n.t('exception.amount_too_high') if amount > 200
    trigrammes = params[:trigramme].select { |t| t.size == 3 }.map(&:to_s).map(&:upcase)
    accounts = Account.where(trigramme: trigrammes)
    fail TdbException, I18n.t('exception.no_account_specified') if accounts.empty?
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
