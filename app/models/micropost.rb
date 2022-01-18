class Micropost < ApplicationRecord
  # マイクロポストがユーザーに所属する
  belongs_to :user
  
  # マイクロポストを順序付け
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
