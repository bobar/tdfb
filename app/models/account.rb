class Account < ActiveRecord::Base
  has_many :transactions, class_name: :Transaction, foreign_key: :id

  has_one :user, foreign_key: :frankiz_id, primary_key: :frankiz_id

  # 0=X platal,1=X
  # ancien,2=binet,3=personnel,4=autre
  # etudiant,5=autre

  enum status: { x_platal: 0, x_ancien: 1, binet: 2, personnel: 3, etudiant_non_x: 4, autre: 5 }

  GENGEN_FRANKIZ_ID = 135
  MANOU_FRANKIZ_ID = 12_368
  DEFAULT_BANK_ID = 1
  DEFAULT_BANK_TRIGRAMME = 'BOB'.freeze

  scope :x, -> { where(status: Account.statuses.slice(:x_platal, :x_ancien).values) }

  def self.default_bank
    find(DEFAULT_BANK_ID)
  end

  def self.search(term)
    terms = term.gsub(/[^a-zA-Z0-9]/, ' ').split(' ')
    clause = terms.map do |t|
      "(LOWER(name) LIKE #{connection.quote('%' + t + '%')} OR LOWER(first_name) LIKE #{connection.quote('%' + t + '%')})"
    end.join(' AND ')
    where(clause).order('CASE WHEN trigramme IS NULL THEN 1 ELSE 0 END', promo: :desc, name: :asc, first_name: :asc)
  end

  def autocomplete_text(with_trigramme: true)
    text = ''
    text += "#{trigramme} - " if trigramme && with_trigramme
    text += "#{promo} " if promo && promo != 0
    text += "#{first_name} #{name}"
    text += " (#{budget} €)" if balance != 0
    text.html_safe
  end

  def full_name
    "#{first_name} #{name}"
  end

  def budget # Returns budget in euros
    (balance / 100.0).round(2)
  end

  def age
    return nil if birthdate.nil?
    today = Date.current
    age = today.year - birthdate.year
    age -= 1 if today.month < birthdate.month
    age -= 1 if today.month == birthdate.month && today.day < birthdate.day
    age
  end

  def birthday?
    birthdate && Date.current.month == birthdate.month && Date.current.day == birthdate.day
  end

  def local_picture
    files = Dir[Rails.root.join('app', 'assets', 'images', 'accounts', "#{id}.*")]
    return files.first.gsub(Rails.root.join('app', 'assets', 'images').to_s + '/', '') unless files.empty?
    return unless File.exist?(picture)
    extension = File.extname(picture)
    path = Rails.root.join('app', 'assets', 'images', 'accounts', "#{id}#{extension}")
    FileUtils.cp(picture, path)
    path.to_s.gsub(Rails.root.join('app', 'assets', 'images').to_s + '/', '')
  end

  def fkz_picture
    return if frankiz_id.nil?
    user = User.find_by(frankiz_id: frankiz_id)
    return unless user
    return if user.picture.nil?
    "https://www.frankiz.net/#{user.picture}"
  end

  def display_picture
    local_picture || fkz_picture
  end

  def possible_users
    return User.find_by(frankiz_id: frankiz_id) if frankiz_id
    # full name match?
    users = User.where(promo: promo).where('name LIKE ? AND name LIKE ?', "#{first_name}%", "% #{name}%")
    return users.first if users.size == 1
    # Casert match ?
    users = User.where(promo: promo, casert: "X#{casert.gsub(/[^\d]/, '')}")
    return users.first if users.size == 1
    User.where(promo: promo).where('name LIKE ? AND name LIKE ?', "#{first_name.first}%", "% #{name.first}%") # Same initials
  end

  def readable_status
    status.to_s.tr('_', ' ').capitalize
  end

  def bank_display_name
    res = trigramme
    if first_name || name
      res ||= ''
      res += ' -'
      res += " #{first_name.capitalize}" if first_name
      res += " #{name.capitalize}" if name
    end
    res
  end

  def send_fascisation_mail(admin)
    sent_mail = AccountMailer.debt(self).deliver_now
    fail TdbException, I18n.t('exception.mail_could_not_be_sent') unless sent_mail.is_a? Mail::Message
    Transaction.create(
      buyer_id: id,
      receiver_id: id,
      amount: 0,
      admin: admin.try(:id),
      comment: "Mail de négatif envoyé à #{mail} (solde #{budget})",
      date: Time.current,
    )
  end
end
