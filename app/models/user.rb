class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise          :database_authenticatable, :registerable,
                 :recoverable,             :rememberable, :validatable

  has_many        :posts,        dependent: :destroy
  has_many        :favorites,    dependent: :destroy
  has_many        :post_comments,dependent: :destroy

  has_one_attached :profile_image

  validates       :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates       :introduction, length: {maximum: 50}


  # 検索方法分岐
  def self.looks(search, word)
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?","#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?","%#{word}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?","%#{word}%")
    else
      @user = User.all
    end
  end

  def self.guest
    find_or_create_by!(name: 'guestuser' ,email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "guestuser"
    end
  end

   # is_deletedがfalseならtrueを返すようにしている 退会機能
  def active_for_authentication?
    super && (is_deleted == false)
  end


  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end
end
