class User < ApplicationRecord
  
  # ユーザーがマイクロポストを複数所有する
  # サイト管理者はユーザーを破棄する権限を持つ
  # ユーザーが削除されたときに、そのユーザーに紐付いた（そのユーザーが投稿した）
  # マイクロポストも一緒に削除される
  has_many :microposts, dependent: :destroy
  
  
  # 
  # 外部キーの名前を<class>_idといったパターンとして理解
  
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  # ユーザーを削除したら、ユーザーのリレーションシップも同時に削除される
                                  dependent:   :destroy
  
  
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  
  # following配列の元はfollowed id/follower idの集合
  has_many :following, through: :active_relationships, source: :followed
  
  # :sourceキーは省略可能
  # :followers属性の場合、Railsが「followers」を単数形にして自動的に外部キーfollower_idを探してくれる
  has_many :followers, through: :passive_relationships, source: :follower
  
  
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  
  # メソッド参照
  # create_activation_digestというメソッドを探し
  # ユーザーを作成する前に実行
  before_create :create_activation_digest
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  # has_secure_passwordでは（追加したバリデーションとは別に）
  # オブジェクト生成時に存在性を検証する
  has_secure_password
  
  # 空のパスワード（nil）は新規ユーザー登録時に有効にならない
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    # 記憶ダイジェストがnilの場合にはreturnキーワードで即座にメソッドを終了
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    # データベースへの問い合わせが１回で済む
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # uspdate_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # 現在時刻より2時間以上前（早い）の場合
    reset_sent_at < 2.hours.ago
  end

  # フォローしているユーザーに対応するidの配列を持つマイクロポストをすべて選択（select）する
  # ユーザーのステータスフィードを返す
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    # whereメソッド内の変数に、キーと値のペアを使う
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end
  
  
  # フォロー関連メソッド
  # self（user自身を表すオブジェクト）を省略
  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end
  
  
  
  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      
      # 代入を要するメソッド
      # self.email = email.downcase
      
      # 代入せずに済むメソッド
      email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
  
  
    
end