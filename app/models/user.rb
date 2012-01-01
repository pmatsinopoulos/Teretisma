class User < ActiveRecord::Base

  has_many :posts, :inverse_of => :user, :dependent => :destroy

  # username contains letters or digits and its length is from 3 to 12
  validates :username,  :format => /^[a-zA-Z0-9]{3,12}$/, :uniqueness => true

  validates :password, :presence => true

  # full_name contains letters or _ or - or space, it has to start from letter and minimum lengths is 5 and maximum 30
  validates :full_name, :format => /^[a-zA-Z][ a-zA-Z_-]{4,29}$/

  validates :phone,     :format => { :with => /^\d{7,20}$/, :message => 'Has to have 7 to 20 digits' }

end
