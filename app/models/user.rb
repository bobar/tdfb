class User < ActiveRecord::Base
  has_one :account, foreign_key: :frankiz_id, primary_key: :frankiz_id

  STATUSES = {
    'Polytechniciens' => :x_platal,
    'Doctorants de l\'X' => :etudiant_non_x,
    'Masters de l\'X' => :etudiant_non_x,
    'Anciens comptes' => :x_ancien,
    'NULL' => :autre,
    'PEI' => :etudiant_non_x,
    'IOGS' => :etudiant_non_x,
    'Saint-Cyriens' => :etudiant_non_x,
    'ENSTA' => :etudiant_non_x,
  }.freeze

  def update_account
    account = Account.find_by(frankiz_id: frankiz_id)
    return if account.nil?

    account.update(
      name: last_name || '',
      first_name: first_name || '',
      birthdate: birthdate,
      casert: casert || '',
      status: status,
      promo: promo,
      mail: email || '',
    )
  end

  def self.search(term)
    terms = term.gsub(/[^a-zA-Z0-9]/, ' ').split(' ')
    clause = terms.map do |t|
      "LOWER(name) LIKE #{connection.quote('%' + t.downcase + '%')}"
    end.join(' AND ')
    where(clause).order(promo: :desc, name: :asc)
  end

  def sport_picture
    return nil if sport.nil?
    return nil if sport == 'Sanssection'
    "#{sport.downcase}.png"
  end

  def status
    status = STATUSES[group]
    status = :x_ancien if Date.current > Date.new(promo.to_i + 3, 5, 1) && status == :x_platal
    status
  end

  def autocomplete_text
    "#{promo} - #{name}"
  end
end
