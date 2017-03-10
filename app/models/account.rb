class Account < ActiveRecord::Base
  has_many :transactions, class_name: :Transaction, foreign_key: :id

  # 0=X platal,1=X
  # ancien,2=binet,3=personnel,4=autre
  # etudiant,5=autre

  enum role: { 'X Platal': 0, 'X Ancien': 1, 'Binet': 2, 'Personnel': 3, 'Etudiant non-X': 4, 'Autre': 5 }

  MANOU_FRANKIZ_ID = 12_368

  def self.default_bank
    find(1)
  end

  def self.search(term)
    return where('LOWER(trigramme) = ?', term.downcase) if term.size == 3
    where('LOWER(name) LIKE ? OR LOWER(first_name) LIKE ?', "%#{term.downcase}%", "%#{term.downcase}%")
      .order('ISNULL(trigramme)', promo: :desc, name: :asc, first_name: :asc)
  end

  def autocomplete_text
    text = ''
    text += "#{trigramme} - " if trigramme
    text += "#{promo} " if promo && promo != 0
    text += "#{first_name} #{name}"
    text += " (#{budget} €)" if balance != 0
    text.html_safe
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

  def possible_users
    return User.find_by(frankiz_id: frankiz_id) if frankiz_id
    # full name match?
    users = User.where(promo: promo).where('name LIKE ? AND name LIKE ?', "#{first_name}%", "% #{name}%")
    return users.first if users.size == 1
    User.where(promo: promo).where('name LIKE ? AND name LIKE ?', "#{first_name.first}%", "% #{name.first}%") # Same initials
  end
end
