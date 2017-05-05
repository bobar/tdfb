class User < ActiveRecord::Base
  has_one :account, foreign_key: :frankiz_id, primary_key: :frankiz_id

  STATUSES = {
    'Polytechniciens' => 0,
    'Doctorants de l\'X' => 4,
    'Masters de l\'X' => 4,
    'Anciens comptes' => 1,
    'NULL' => 5,
    'PEI' => 4,
    'IOGS' => 4,
    'Saint-Cyriens' => 4,
    'ENSTA' => 4,
  }.freeze

  def update_account
    account = Account.find_by(frankiz_id: frankiz_id)
    return if account.nil?

    status = STATUSES[group]
    status = 1 if Date.current > Date.new(promo.to_i + 3, 5, 1) && status == 0

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

  def status
    STATUSES[group]
  end

  def autocomplete_text
    "#{promo} - #{name}"
  end
end
