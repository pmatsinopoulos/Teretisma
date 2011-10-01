class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username,  :null => false, :limit => 12
      t.string :password,  :null => false # this is really bad. Actually, we should encrypt with one-way encryption.
      t.string :full_name, :null => false, :limit => 30
      t.string :phone,     :null => false, :limit => 20

      t.timestamps
    end

    add_index :users, [:username], :unique => true, :name => "users_username_uidx"
  end

  def self.down
    drop_table :users
  end
end
