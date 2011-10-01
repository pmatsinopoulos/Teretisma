class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :user_id, :null => false
      t.string :title,    :null => false, :limit => 140

      t.timestamps
    end

    add_foreign_key :posts, :users, :column => "user_id", :name => "posts_users_fk"
  end

  def self.down
    drop_table :posts
  end
end
