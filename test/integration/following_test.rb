# show_followの描画結果を確認するテスト

require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    
    # プロフィール画面のfollowingの数をテスト
    assert_match @user.following.count.to_s, response.body
    
    # 正しいURLかどうかをテスト
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    
    # フォロワーが0人(文字列が空)ではない時に実行
    # @user.followers.empty?が真の時、以下のテストは実行しない
    assert_not @user.followers.empty?
    
    # プロフィール画面のfollowersの数をテスト
    assert_match @user.followers.count.to_s, response.body
    
    
    # フォロワーのページが正しいURLかどうかをテスト
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
  
  # ［Follow］/［Unfollow］ボタンをテスト
  test "should follow a user the standard way" do
    
    # /relationshipsに対してPOSTリクエストを送り、フォローされたユーザーが1人増えたことをチェック
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    
    # /relationshipsに対してDELETEリクエストを送り、フォローしている数が1つ減ることを確認
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
end