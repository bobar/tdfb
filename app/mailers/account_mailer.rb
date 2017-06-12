class AccountMailer < ActionMailer::Base
  default from: 'Le BôBar <bobar.tdb@gmail.com>'
  default bcc: 'bobar.tdb@gmail.com'

  def debt(account)
    @account = account
    return nil unless account.balance < 0
    return nil unless account.x_platal?
    return nil if account.mail.nil? || account.mail.blank?
    mail(
      to: account.mail,
      reply_to: 'Le BôBar <bobar@binets.polytechnique.fr>',
      subject: I18n.t('debt_mail.subject'),
    )
  end
end
