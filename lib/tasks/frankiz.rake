namespace :frankiz do
  task update_all: :environment do
    username = ENV['fkz_user'] || user_prompt('Frankiz login? ')
    password = ENV['fkz_pass'] || user_prompt('Frankiz password? ', secret: true)
    fkz = FrankizCrawler.new(username, password)
    ids = User.uniq.pluck(:frankiz_id)
    progress_bar(0, ids.size)
    ids.each_with_index do |id, idx|
      fkz.get(id, true)
      progress_bar(idx + 1, ids.size, detail: "Getting frankiz user #{id}")
    end
  end

  task :crawl, [:from, :to] => :environment do |_, args|
    username = ENV['fkz_user'] || user_prompt('Frankiz login? ')
    password = ENV['fkz_pass'] || user_prompt('Frankiz password? ', secret: true)
    fkz = FrankizCrawler.new(username, password)
    WrongFrankizId.where('frankiz_id > ?', User.maximum(:frankiz_id)).delete_all
    from = (args[:from] || 0).to_i
    upto = (args[:to] || [Account::MANOU_FRANKIZ_ID, User.maximum(:frankiz_id), WrongFrankizId.maximum(:frankiz_id)].compact.max + 1000).to_i
    known_frankiz_ids = User.uniq.pluck(:frankiz_id).concat(WrongFrankizId.all.pluck(:frankiz_id))
    todo = ((from..upto).to_a - known_frankiz_ids)
    todo.each_with_index do |id, i|
      fkz.get(id, true) unless known_frankiz_ids.include?(id)
      progress_bar(i + 1, todo.size + 1, detail: "Getting frankiz user #{id}")
    end
  end

  task :refresh_promo, [:promo] => :environment do |_, args|
    username = ENV['fkz_user'] || user_prompt('Frankiz login? ')
    password = ENV['fkz_pass'] || user_prompt('Frankiz password? ', secret: true)
    fkz = FrankizCrawler.new(username, password)
    users = User.where(promo: args[:promo])
    progress_bar(0, users.size)
    users.each_with_index do |u, idx|
      fkz.get(u.frankiz_id, true)
      u.update_account(true)
      progress_bar(idx + 1, users.size, detail: "Refreshing frankiz user #{u.frankiz_id}")
    end
  end

  task :associate_accounts, [:promo] => :environment do |_, args|
    doubtful = 0
    Account.where(frankiz_id: nil, promo: args[:promo]).where(status: User::STATUSES.values.uniq).each do |acc|
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
