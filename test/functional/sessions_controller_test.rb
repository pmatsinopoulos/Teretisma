require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  # Routing

  test "routing" do
    assert_recognizes({:controller => "sessions", :action => "new"}, "/login")
    assert_generates("/login", {:controller => "sessions", :action => "new"})

    assert_recognizes({:controller => "sessions", :action => "destroy"},
                      :path => "/logout", :method => :delete)
    assert_generates("/logout", {:controller => "sessions", :action => "destroy"})

    assert_recognizes({:controller => "sessions", :action => "create"},
                      :path => "/login", :method => "post")
    assert_generates("/login", {:controller => "sessions", :action => "create"} )
  end

  # GET /login

  test "new should not require authentication" do
    @controller.expects(:authenticate).never()
    get :new
  end

  test "new should succeed" do
    get :new
    assert_response :success
    assert_template :new
  end

  # DELETE / logout
  test "destroy should not require authentication" do
    @controller.expects(:authenticate).never()
    delete :destroy
  end

  test "destroy should set session user id to nil" do
    # prepare
    login_as(users(:petros))
    assert session[:user_id].present?

    # fire
    delete :destroy

    # assert
    assert session[:user_id].nil?
  end

  test "destroy should redirect to root path" do
    # prepare
    login_as(users(:petros))
    assert session[:user_id].present?

    # fire
    delete :destroy

    # assert
    assert_redirected_to root_path
  end

  # POST /login
  #
  test "create should not require authentication" do
    @controller.expects(:authenticate).never()
    post :create
  end

  test "create successful log in and redirects to return_to param" do
    # prepare
    user = users(:petros)

    # fire
    post :create, :username => user.username, :password => user.password, :return_to => users_path

    # assert
    assert_redirected_to users_path
    assert_equal flash[:notice], "You have successfully logged in"
  end

  test "create valid username invalid password" do
    # prepare
    user = users(:petros)

    # fire
    post :create, :username => user.username, :password => user.password.reverse, :return_to => users_path

    # assert
    assert_response :forbidden
    assert_template :new
    assert_equal flash[:alert], "Invalid credentials. Please, try again"
  end

  test "create with invalid username" do
    # fire
    post :create, :username => Time.now.to_s, :password => "something", :return_to => users_path

    # assert
    assert_response :forbidden
    assert_template :new
    assert_equal flash[:alert], "Invalid credentials. Please, try again"
  end

end
