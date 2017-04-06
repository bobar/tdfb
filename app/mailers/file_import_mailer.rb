class FileImportMailer < ActionMailer::Base
  default from: 'bobar.tdb@gmail.com'

  def cancelled_debits(to, file)
    attachments[File.basename(file)] = File.read(file)
    mail(to: to, subject: I18n.t('file_import_cancelled_mail.subject'))
  end
end
