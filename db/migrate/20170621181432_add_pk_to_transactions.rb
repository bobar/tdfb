class AddPkToTransactions < ActiveRecord::Migration
  def change
    rename_column :transactions, :id, :buyer_id
    rename_column :transactions, :id2, :receiver_id
    rename_column :transactions, :price, :amount

    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute 'ALTER TABLE `transactions` ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST'
        ActiveRecord::Base.connection.execute 'ALTER TABLE `transactions` ENGINE=InnoDB'
        ActiveRecord::Base.connection.execute 'ALTER TABLE `transactions` CONVERT TO CHARACTER SET utf8mb4'
      end
      dir.down do
        ActiveRecord::Base.connection.execute 'ALTER TABLE `transactions` CONVERT TO CHARACTER SET latin1'
        ActiveRecord::Base.connection.execute 'ALTER TABLE `transactions` Engine=MyISAM'
        remove_column :transactions, :id
      end
    end
  end
end
