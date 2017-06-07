namespace :frankiz do
  task :refresh_promo, [:promo] => :environment do |_, args|
    fkz = FrankizLdap.new
    fkz.crawl_promo(args[:promo])
  end

  task :associate_accounts, [:promo] => :environment do |_, args|
    doubtful = 0
    Account.where(frankiz_id: nil, promo: args[:promo]).where.not(status: Account.statuses[:binet]).each do |acc|
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
