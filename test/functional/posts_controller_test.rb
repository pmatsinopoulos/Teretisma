require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  # Routing

  test "routing" do
    assert_recognizes({:controller => "posts", :action => "new", :user_id => "1"}, "/users/1/posts/new")
    assert_generates("/users/1/posts/new", {:controller => "posts", :action => "new", :user_id => "1"})

    assert_recognizes({:controller => "posts", :action => "create", :user_id => "1"},
                      :path => "/users/1/posts", :method => :post)
    assert_generates("/users/1/posts", {:controller => "posts", :action => "create", :user_id => "1"})

    assert_recognizes({:controller => "posts", :action => "index", :user_id => "1"}, "/users/1/posts")
    assert_generates("/users/1/posts", {:controller => "posts", :action => "index", :user_id => "1"})

    assert_recognizes({:controller => "posts", :action =>"index_all"}, "/posts")
    assert_generates("/posts", {:controller => "posts", :action =>"index_all"})

    assert_recognizes({:controller => "posts", :action => "destroy", :user_id => "1", :id => "2"},
                      :path => "/users/1/posts/2", :method => "delete")
    assert_generates("/users/1/posts/2", {:controller => "posts", :action => "destroy", :user_id => "1", :id => "2"})

    assert_recognizes({:controller => "posts", :action => "more_posts"}, "/posts/more_posts")
    assert_generates("/posts/more_posts", {:controller => "posts", :action => "more_posts"})

    assert_recognizes({:controller => "posts", :action => "show", :user_id => "1", :id => "2"}, "/users/1/posts/2")
    assert_generates("/users/1/posts/2", {:controller => "posts", :action => "show", :user_id => "1", :id => "2"})
  end

  # GET new

  test "new requires authentication" do
    @controller.expects(:authenticate)
    get :new, :user_id => users(:petros).to_param
  end

  test "new redirects to login if user is not logged in" do
    # prepare
    user = users(:petros).to_param

    # fire
    get :new, :user_id => user.to_param

    # assert
    assert_redirected_to login_path(:return_to => new_user_post_path(:user_id => user.to_param))
  end

  test "new should not require authorization" do
    # prepare
    user = users(:petros)
    login_as(user)
    @controller.expects(:authorize).never()

    # fire
    get :new, :user_id => user.to_param
  end

  test "new succeeds" do
    # prepare
    user = users(:petros)
    login_as(user)

    # fire
    get :new, :user_id => user.to_param

    # assert
    assert_response :success
    assert_assigns(:post)
    assigned_post = assigns(:post)
    assert_equal user, assigned_post.user
  end

  # POST create

  test "create should require authentication" do
    @controller.expects(:authenticate)
    post :create, :post => {:title => 'title'}, :user_id => users(:petros).to_param
  end

  test "create should redirect to login is user is not logged in" do
    post :create, :post => {:title => 'title'}, :user_id => users(:petros).to_param
    assert_redirected_to login_path(:return_to => @controller.request.fullpath)
  end

  test "create should do authorization" do
    ## prepare
    user = users(:petros)
    login_as(user)

    @controller.expects(:authorize)

    # fire
    post :create, :post => {:title => 'title'}, :user_id => user.to_param
  end

  test "create should succeed" do
    # prepare
    user = users(:petros)
    login_as(user)

    # fire and assert
    assert_difference "Post.count", +1 do
      post :create, :user_id => user.to_param, :post => {:title => 'Hello Post'}
    end

    assert_response :success
    assert_template :show
    assert_equal "Post has been created sccessfully", flash[:notice]
    assert_assigns :post
    assigned_post = assigns(:post)
    assert_equal 'Hello Post', assigned_post.title
    assert_equal user.id, assigned_post.user.id
  end

  test "create on error would render new again" do
    # prepare
    user = users(:petros)
    login_as(user)

    # this will generate error
    assert_no_difference "Post.count" do
      post :create, :user_id => user.to_param, :post => {:title => ''}
    end
    assert_response :unprocessable_entity
    assert_template :new
    assert_equal flash[:alert], 'Cannot create post'
  end

  # GET index

  test "index should not require authentication" do
    # prepare
    @controller.expects(:authenticate).never()
    user = users(:petros)

    # fire
    get :index, :user_id => user.to_param
  end

  test "index should not require authorization" do
    # prepare
    user = users(:petros)
    @controller.expects(:authorize).never()

    # fire
    get :index, :user_id => user.to_param
  end

  test "index should succeed" do
    # prepare
    user = users(:petros)

    # make sure that he has some posts
    assert user.posts.length >= 1
    # make sure that there are posts of other users too
    assert user.posts.length != Post.all.length

    get :index, :user_id => user.to_param
    assert_response :success
    assert_template :index
    assert_assigns(:posts)
    assigned_posts = assigns(:posts)

    # check that this includes the posts of petros and only petros posts
    assert_equal assigned_posts.length, user.posts.length
    assert assigned_posts.all?{ |p| p.user.id == user.id }
  end

  # GET /users/:user_id/posts/:id

  test "show should not require authentication" do
    # prepare
    user = users(:petros)
    @controller.expects(:authenticate).never()

    # fire
    get :show, :user_id => user.to_param, :id => user.posts.first
  end

  test "show should not require authorization" do
    # prepare
    user = users(:petros)
    @controller.expects(:authorize).never()

    # fire
    get :show, :user_id => user.to_param, :id => user.posts.first
  end

  test "show should succeed" do
    # prepare
    post = posts(:petros_first)

    # fire
    get :show, :user_id => post.user.to_param, :id =>post.to_param

    # assert
    assert_response :success
    assert_template :show
    assert_assigns(:post)
    assigned_post = assigns(:post)
    assert_equal post.id, assigned_post.id
  end

  # GET index_all

  test "index_all should not require authentication" do
    @controller.expects(:authenticate).never()
    get :index_all
  end

  test "index_all should not require authorization" do
    @controller.expects(:authorize).never()
    get :index_all
  end

  test "index_all should succeed with html format" do
    # make sure that there are some posts
    assert Post.all.length >= 1
    Post.expects(:index_all).with(nil).returns(Post.all)

    # fire
    get :index_all

    assert_response :success
    assert_template :index

    assert_equal "text/html", @controller.content_type

    assert_assigns(:posts)
    assigned_posts = assigns(:posts)
    assert_equal Post.all.length, assigned_posts.length
  end

  test "index_all should succeed with html format and limit" do
    # make sure that there are some posts
    assert Post.all.length >= 3
    Post.expects(:index_all).with(2).returns(Post.order('created_at desc').limit(2))

    # fire
    get :index_all, :limit => 2

    assert_response :success
    assert_template :index

    assert_equal "text/html", @controller.content_type

    assert_assigns(:posts)
    assigned_posts = assigns(:posts)
    assert_equal 2, assigned_posts.length
  end

  test "index_all should succeed with rss format" do
    # prepare
    assert Post.all.length >= 1
    posts = Post.joins(:user).
                order("posts.created_at desc").
                select("posts.id, users.id as user_id, users.full_name, posts.title, posts.created_at")
    Post.expects(:feed_index_all).with(nil).returns(posts)

    # fire
    get :index_all, :format => :rss

    # assert
    assert_response :success
    assert_template :index, :format => :rss
    assert_equal :rss, @controller.params[:format]
    assert_equal "application/rss+xml", @controller.content_type

    assert_assigns(:posts)
    assigned_posts = assigns(:posts)
    assert_equal Post.all.length, assigned_posts.length

    a_post = assigned_posts.first
    assert a_post.respond_to?(:id)
    assert a_post.respond_to?(:user_id)
    assert a_post.respond_to?(:full_name)
    assert a_post.respond_to?(:title)
    assert a_post.respond_to?(:created_at)
  end

  test "index_all should succeed with rss format with limit" do
    # prepare
    assert Post.all.length >= 3
    posts = Post.joins(:user).
                order("posts.created_at desc").
                limit(2).
                select("posts.id, users.id as user_id, users.full_name, posts.title, posts.created_at")
    Post.expects(:feed_index_all).with(2).returns(posts)

    # fire
    get :index_all, :format => :rss, :limit => 2

    # assert
    assert_response :success
    assert_template :index, :format => :rss
    assert_equal :rss, @controller.params[:format]
    assert_equal "application/rss+xml", @controller.content_type

    assert_assigns(:posts)
    assigned_posts = assigns(:posts)
    assert_equal 2, assigned_posts.length

    a_post = assigned_posts.first
    assert a_post.respond_to?(:id)
    assert a_post.respond_to?(:user_id)
    assert a_post.respond_to?(:full_name)
    assert a_post.respond_to?(:title)
    assert a_post.respond_to?(:created_at)
  end

  test "index_all view test when logged out" do
    # prepare
    # make sure that there are some posts
    assert Post.all.length >= 1

    # fire
    get :index_all

    # assert
    assert_response :success
    assert_template :index
    assert_select "div.menu_item a", 5 do |elements|
      elements.any?{|elem| elem.children[0].content == "Sign Up"}
      elements.any?{|elem| elem.children[0].content == "Sign In"}
      elements.any?{|elem| elem.children[0].content == "Registered Users"}
      elements.all?{|elem| elem.children[0].content != "Post"}
      elements.any?{|elem| elem.children[0].content == "All Posts"}
      elements.all?{|elem| elem.children[0].content != "My Posts"}
      elements.any?{|elem| elem.children[0].content == "Subscribe to RSS Feeds"}
    end

    # there is no logout link
    assert_select "a[href='/logout']", 0

    # there are no delete links
    assert_select "a[data-method='delete']", 0
  end

  test "index_all view test when logged in" do
    # prepare
    user = users(:petros)
    login_as(user)
    # make sure that he has some posts
    assert user.posts.length >= 1
    # make sure that there are other posts too
    assert user.posts.length != Post.all.length

    # fire
    get :index_all

    # assert
    assert_response :success
    assert_template :index
    assert_select "div.menu_item a", 6 do |elements|
      elements.any?{|elem| elem.children[0].content == "Sign Up"}
      elements.all?{|elem| elem.children[0].content != "Sign In"}
      elements.any?{|elem| elem.children[0].content == "Registered Users"}
      elements.any?{|elem| elem.children[0].content == "Post"}
      elements.any?{|elem| elem.children[0].content == "All Posts"}
      elements.any?{|elem| elem.children[0].content == "My Posts"}
      elements.any?{|elem| elem.children[0].content == "Subscribe to RSS Feeds"}
    end
    # there is a log out link too
    assert_select "a[href='/logout']", 1

    # there are so many delete links as the number of posts of user logged in
    selected = css_select "div#table_with_posts a[data-method='delete']"
    assert_equal user.posts.length, selected.collect{ |s| s["href"].match("users/#{user.id}/posts/") }.length
  end

  # DELETE /users/:user_id/posts/:id

  test "destroy should require authentication" do
    # prepare
    user = users(:petros)
    @controller.expects(:authenticate)

    # fire
    delete :destroy, :user_id => user.to_param, :id => user.posts.first.to_param
  end

  test "destroy should require authorization" do
    # prepare
    user = users(:petros)
    login_as(user)
    @controller.expects(:authorize)

    # fire
    delete :destroy, :user_id => user.to_param, :id => user.posts.first.to_param
  end

  test "destroy on error should render show" do
    # prepare
    user = users(:petros)
    login_as(user)
    Post.any_instance.expects(:destroy).raises(ActiveRecord::ActiveRecordError.new)

    # fire
    delete :destroy, :user_id => user.to_param, :id => user.posts.first.to_param

    # assert
    assert_response :unprocessable_entity
    assert_template :show
    assert_assigns :post
    assert_match /Cannot delete post/, flash[:alert]
  end

  test "destroy should succeed" do
    # prepare
    user = users(:petros)
    login_as(user)
    assert user.posts.length >= 1
    post = user.posts.order('created_at desc').first
    assert_present post

    # fire and assert
    assert_difference 'Post.count', -1 do
      delete :destroy, :user_id => user.to_param, :id => post.to_param
    end
    assert_redirected_to user_posts_path(user)
    assert_match /Post deleted successfully/, flash[:notice]
  end

  # GET /posts/more_posts

  test "more_posts does not require authentication" do
    @controller.expects(:authenticate).never()
    get :more_posts
  end

  test "more posts should not require authorization" do
    @controller.expects(:authorize).never()
    get :more_posts
  end

  test "more_posts should succeed" do
    get :more_posts
    assert_response :success
    assert_template :more_posts
  end

  test "more_posts should return the correct number of posts" do
    # prepare
    posts_length = Post.all.length
    assert posts_length >= 4

    get :more_posts, :count => 2

    assert_assigns :answer
    answer_assigned = assigns(:answer)
    assert_equal posts_length-2, answer_assigned.to_i
  end

end
