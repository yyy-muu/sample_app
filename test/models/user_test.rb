require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
            password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid?" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email shold not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end



  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  
  # 2種類のブラウザをシミュレートするのは困難
  # 同じ問題をUserモデルで直接テストする
  # 記憶ダイジェストを持たないユーザーを用意し、authenticated?を呼び出す
  test "authenticated? should return false for a user with nil digest" do
    # 記憶トークンが使われる前にエラーが発生するので、記憶トークンの値は空欄
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed" do
    @user.save
    
    # ユーザーを作成することと、そのユーザーに紐付いたマイクロポストを作成
    @user.microposts.create!(content: "Lorem ipsum")
    
    # ユーザーを削除し、マイクロポストの数が1つ減っているかどうかを確認
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    
    # ユーザーをまだフォローしていないことを確認
    assert_not michael.following?(archer)
    
    # そのユーザーをフォロー
    michael.follow(archer)
    
    # フォロー中になったことを確認
    assert michael.following?(archer)
    
    # フォロワーのデータモデルが正しく動作していることを確認
    # フォロワーの中に追加されているか(含まれているか)確認
    assert archer.followers.include?(michael)
    
    # フォロー解除
    michael.unfollow(archer)
    # フォロー解除できたことを確認
    assert_not michael.following?(archer)
  end
  
end
