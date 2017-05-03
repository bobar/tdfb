class IssueMailer < ActionMailer::Base
  default from: 'bobar.tdb@gmail.com'
  default to: 'bobar.tdb+issue@gmail.com'

  def issue(name, email, subject, body)
    mail(
      reply_to: "#{name} <#{email}>",
      subject: subject,
      body: body,
    )
  end
end
