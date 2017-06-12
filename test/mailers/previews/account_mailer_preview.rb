class AccountMailerPreview < ActionMailer::Preview
  def debt
    account = Account.x_platal.where('balance < 0').order(:balance)[5]
    # account = Account.find_by(trigramme: 'LOL')
    AccountMailer.debt(account)
  end
end
