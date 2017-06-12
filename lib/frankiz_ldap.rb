class FrankizLdap
  attr_reader :ldap

  GROUP_MAPPING = {
    'doc' => 'Doctorants de l\'X',
    'ensta' => 'ENSTA',
    'grad' => 'Graduate de l\'X',
    'iogs' => 'IOGS',
    'master' => 'Masters de l\'X',
    'pei' => 'PEI',
    'poly' => 'Anciens comptes',
    'stcyr' => 'Saint-Cyriens',
    'x' => 'Polytechniciens',
  }.freeze

  def initialize
    @logger = Logger.new('/tmp/frankiz.log')
    @logger.formatter = -> (_severity, _datetime, _progname, msg) { msg.to_s + "\n" }
    @ldap = Net::LDAP.new(host: 'frankiz.net', post: 389, base: 'dc=frankiz,dc=net')
    @ldap.bind
  end

  def crawl_promo(promo)
    items = []
    (['0', '%'] + ('a'..'z').to_a).each do |initial|
      @logger.info "Querying users starting with #{initial} in promo #{promo}"
      items << ldap.search(filter: "(&(brpromo=#{promo})(uid=#{initial}*))")
    end
    items = items.flatten
    todo = items.size
    items.each_with_index do |item, idx|
      user = insert(item)
      user.update_account
      @logger.info "[#{item[:brpromo].first}] Inserted user #{idx + 1}/#{todo} #{item[:givenname].first} #{item[:sn].first}"
    end
  end

  def get(id, write = false)
    item = @ldap.search(filter: "brmemberof=user_#{id}").first
    insert(item) if item && write
    WrongFrankizId.find_or_create_by(frankiz_id: id) if item.nil?
    item
  end

  def insert(item)
    frankiz_id = item[:brmemberof].find { |group| group =~ /^user_\d+$/ }
    frankiz_id = frankiz_id.tr('user_', '')
    user = User.find_or_initialize_by(frankiz_id: frankiz_id)
    user.update(
      name: item[:cn].first,
      first_name: item[:givenname].first,
      last_name: item[:sn].first,
      email: item[:mail].first,
      promo: item[:brpromo].first,
      group: get_group(item),
      casert: item[:brroom].first,
      birthdate: item[:brbirthdate].first,
      picture: "image/full/#{item[:brphoto].first}",
      sport: item[:brmemberof].find { |group| group.start_with?('sport_') }.try(:gsub, /^sport_(.*)$/, '\1').try(:capitalize),
      updated_at: Time.current,
    )
    user
  end

  def get_group(item)
    raw_group = item[:brmemberof].select { |group| group =~ /^promo_.+#{item[:brpromo].first}$/ }
    Rails.logger.warn "Multiple groups detected: #{item[:brmemberof]}" unless raw_group.size == 1
    raw_group = raw_group.first
    return nil if raw_group.nil?
    raw_group.gsub!(/^promo_(.+)#{item[:brpromo].first}$/, '\1')
    GROUP_MAPPING[raw_group]
  end
end
