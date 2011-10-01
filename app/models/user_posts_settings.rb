class UserPostsSettings < Settingslogic
  source "#{Rails.root}/config/user_posts.yml"
  namespace Rails.env
end