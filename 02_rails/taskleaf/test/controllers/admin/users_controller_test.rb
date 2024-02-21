require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_users_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_users_edit_url
    assert_response :success
  end

  test "should get show" do
    get admin_users_show_url
    assert_response :success
  end

  test "should get index" do
    get admin_users_index_url
    assert_response :success
  end
end
