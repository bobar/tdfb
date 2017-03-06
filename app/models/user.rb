class User < ActiveRecord::Base
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

  def update_account(dry_run = true)
    account = Account.find_by(frankiz_id: frankiz_id)
    return if account.nil?

    first_name = ''
    last_name = ''
    if email =~ /@(institutoptique.fr|polytechnique.edu|polytechnique.org)$/
      first_name = email.split('@').first.split('.')[0].split('-').map(&:capitalize).join(' ')
      last_name = email.split('@').first.split('.')[1].split('-').map(&:upcase).join(' ')
    else
      first_name = name.split(' ')[0].split('-').map(&:capitalize).join('-')
      last_name = name.split(' ')[1..-1].join(' ').upcase
    end

    if dry_run
      old_name = account.first_name + ' ' + account.name
      new_name = first_name + ' ' + last_name
      STDERR.puts "#{old_name} => #{new_name}" if old_name.tr('-', ' ').casecmp(new_name.tr('-', ' ')) == 0
      return
    end

    account.update(
      name: email.split('@').first.split('.')[1].split('-').map(&:upcase).join(' '),
      first_name: email.split('@').first.split('.')[0].split('-').map(&:capitalize).join(' '),
      casert: casert || '',
      status: STATUSES[group],
      promo: promo,
      mail: email,
    )
  end
end
