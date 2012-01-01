require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  # routing
  test "routing" do
    # GET /users/new
    assert_recognizes({:controller => "users", :action => "new"}, "/users/new")
    assert_generates("/users/new", {:controller => "users", :action => "new"})

    # POST /users
    assert_recognizes({:controller => "users", :action => "create"},
                      :path => "/users", :method => "post")
    assert_generates("/users", {:controller => "users", :action => "create"})

    # GET /users
    assert_recognizes({:controller => "users", :action => "index"}, "/users")
    assert_generates("/users", {:controller => "users", :action => "index"})
  end

  # GET /users/new

  test "get new should not require authentication" do
    @controller.expects(:authenticate).never()
    get :new
  end

  test "get new should succeed" do
    get :new
    assert_response :success
    assert_assigns(:user)
  end

  # POST /users

  test "post create should not require authentication" do
    @controller.expects(:autenticate).never()
    post :create
  end

  test "post create on success should direct to users index" do
    user_to_create = users(:petros).dup
    user_to_create.username = user_to_create.username.reverse
    user_to_create.phone = user_to_create.phone.reverse
    assert_difference "User.count", +1 do
      post :create, :user => user_to_create.attributes
    end
    assert_redirected_to root_path
    assert flash[:notice].present?
  end

  test "post create on invalid record error should render new" do

    assert_no_difference "User.count" do
      post :create, :user => {}
    end
    assert_response :unprocessable_entity
    assert_template :new
  end

  # GET /users

  test "get index should not require authentication" do
    @controller.expects(:authenticate).never()
    get :index
  end

  test "get index should succeed" do
    get :index
    assert_response :success
    assert_assigns(:users)
    users_assigned = assigns(:users)
    # check order by full_name
    i = 1
    while ( i<users_assigned.length )
      assert users_assigned[ i ].full_name >= users_assigned[ i - 1 ].full_name
      i += 1
    end
  end
end
