class Account < ActiveRecord::Base
  has_many :transactions, class_name: :Transaction, foreign_key: :id

  MANOU_FRANKIZ_ID = 12_368

  def self.search(term)
    where(trigramme: term) + where('LOWER(name) LIKE ? OR LOWER(first_name) LIKE ?', "%#{term.downcase}%", "%#{term.downcase}%")
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
