require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
  end

  # 作成したマイクロポストが有効かどうかをチェック
  test "should be valid" do
    assert @micropost.valid?
  end

  # user_idの存在性のバリデーションに対するテスト
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  # content属性の存在
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # 140文字より長くない
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
  
  # データベース上の最初のマイクロポストが
  # fixture内のマイクロポスト（most_recent）と同じである
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end