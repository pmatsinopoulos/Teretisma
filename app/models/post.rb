class Post < ActiveRecord::Base

  belongs_to :user, :inverse_of => :posts

  validates :user_id, :presence => true
  validates :title,   :presence => true, :length => {:maximum => 140}

  class << self
    def feed_index_all(limit=nil)
      posts = Post.joins(:user).
                order("posts.created_at desc").
                select("posts.id, users.id as user_id, users.full_name, posts.title, posts.created_at")
      posts = posts.limit(limit) if limit.present?
      posts
    end

    def index_all(limit=nil)
      posts = Post.order('created_at desc')
      posts = posts.limit(limit) if limit.present?
      posts
    end
  end
end
