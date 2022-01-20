class Micropost < ApplicationRecord
  # マイクロポストがユーザーに所属する
  belongs_to :user
  
  # 指定のモデル(image)と、アップロードされたファイルを関連付ける
  # Active Storage API
  has_one_attached :image
  
  # マイクロポストを順序付け
  default_scope -> { order(created_at: :desc) }
  
  # validates
  # オブジェクトがDBに保存される前に、そのデータが正しいかどうかを検証する仕組み
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message: "should be less than 5MB" }

  # 表示用のリサイズ済み画像を返す
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end

end
