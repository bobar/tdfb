require 'gmail'

namespace :db do
  task :sync_from_save, [:password] => :environment do |_, args|
    conf = Rails.configuration.database_configuration[Rails.env]

    backup_path = Rails.root.to_s + '/tmp/Backup_' + Time.now.utc.iso8601
    `mysqldump -u#{conf['username']} -p#{conf['password']} #{conf['database']} > #{backup_path}`

    path = ''
    Gmail.new('bobar.save@gmail.com', args[:password]) do |gmail|
      tdb_dump = gmail.inbox.emails.last.attachments.first
      path = Rails.root.to_s + '/' + tdb_dump.filename
      file = File.new(path, 'w+', encoding: 'ascii-8bit')
      file << tdb_dump.decoded
      file.close
    end
    `gzip -dc #{path} | mysql -u#{conf['username']} -p#{conf['password']} #{conf['database']}`
    `rm #{path}`
  end
end
