namespace :frankiz do
  task update_all: :environment do
    username = ENV['fkz_user'] || user_prompt('Frankiz login? ')
    password = ENV['fkz_pass'] || user_prompt('Frankiz password? ', secret: true)
    fkz = FrankizCrawler.new(username, password)
    ids = Account.uniq.pluck(:frankiz_id)
    progress_bar(0, ids.size)
    ids.each_with_index do |id, idx|
      fkz.get(id, true)
      progress_bar(idx + 1, ids.size, detail: "Getting frankiz user #{id}")
    end
  end

  task :crawl, [:upto] => :environment do |_, args|
    username = ENV['fkz_user'] || user_prompt('Frankiz login? ')
    password = ENV['fkz_pass'] || user_prompt('Frankiz password? ', secret: true)
    fkz = FrankizCrawler.new(username, password)
    upto = (args.upto || [Account::MANOU_FRANKIZ_ID, Account.maximum(:frankiz_id), WrongFrankizId.maximum(:frankiz_id)].compact.max + 500).to_i
    known_frankiz_ids = Account.uniq.pluck(:frankiz_id).concat(WrongFrankizId.all.pluck(:frankiz_id)).to_set
    (0..upto).each do |id|
      fkz.get(id, true) unless known_frankiz_ids.include?(id)
      progress_bar(id + 1, upto + 1, detail: "Getting frankiz user #{id}")
    end
  end
end
