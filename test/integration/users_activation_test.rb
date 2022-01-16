require 'test_helper'

class UsersActivationTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @non_activated_user = users(:red)
  end

  test "index only activated user" do
    log_in_as(@user)
    get users_path
    # @userへのリンクがあることを確認
    assert_select "a[href=?]", user_path(@user)
    # @non_activated_userへのリンクがないことを確認
    assert_select "a[href=?]", user_path(@non_activated_user), count: 0
  end

  # showページはactivatedユーザーのみ
  test "show only activated user" do
    log_in_as(@user)
    get user_path(@user)
    
    # ＠non_activated_userの詳細ページにアクセスすると、ルートURLにリダイレクトされる
    get user_path(@non_activated_user)
    assert_redirected_to root_url
  end

end