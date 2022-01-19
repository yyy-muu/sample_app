class User < ApplicationRecord
  
  # ユーザーがマイクロポストを複数所有する
  # サイト管理者はユーザーを破棄する権限を持つ
  # ユーザーが削除されたときに、そのユーザーに紐付いた（そのユーザーが投稿した）
  # マイクロポストも一緒に削除される
  has_many :microposts, dependent: :destroy
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
  
  # フィード(未完成)
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    # idに?を代入、SQLクエリに代入する前にidがエスケープされる
    # SQLインジェクション対策
    Micropost.where("user_id = ?", id)
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