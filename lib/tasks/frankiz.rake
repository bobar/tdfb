namespace :frankiz do
  task :refresh_promo, [:promo] => :environment do |_, args|
    FrankizLdap.new.crawl_promo(args[:promo])
  end

  task refresh_oldest_promo: :environment do
    promo = User.select(:promo, 'MIN(updated_at) updated_at')
      .where.not(promo: nil)
      .group(:promo)
      .having('COUNT(1) > 1')
      .order(:updated_at).first.promo
    promo = User.maximum(:promo).to_i + 1 if Random.rand(10) == 0
    FrankizLdap.new.crawl_promo(promo)
  end

  task :associate_accounts, [:promo] => :environment do |_, args|
    doubtful = 0
    Account.where(frankiz_id: nil, promo: args[:promo], status: [0, 1]).each do |acc|
      users = acc.possible_users
      next if users.nil? || users.try(:empty?)
      if users.is_a? User
        acc.update(frankiz_id: users.frankiz_id)
      else
        doubtful += 1
        puts ''
        puts acc.as_json
        puts 'has several possible matches:'
        users.each_with_index do |u, i|
          puts "\t#{i + 1}:\t#{u.as_json(only: [:name, :email, :promo, :group, :casert])}"
        end
        idx = user_prompt('Which one should we use? (0 to skip):').to_i
        next if idx < 1 || idx > users.size
        acc.update(frankiz_id: users[idx - 1].frankiz_id)
      end
    end
    puts "#{doubtful} doubtful accounts"
  end
end
