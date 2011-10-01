class PostsController < ApplicationController

  # We will not authenticate the user that is trying to see the Posts.
  skip_before_filter :authenticate, :only => [:index, :index_all, :show, :more_posts]

  # Creation and Deletion of post, requires authorization. A user can delete only the
  # posts that he owns. Also, he can create posts only under his account.
  before_filter :authorize, :only => [:create, :destroy]

  # GET /users/:user_id/posts/new
  #
  # This is requesting the form to create a new post
  def new
    @post = Post.new(:user => current_user)
  end

  # POST /users/:user_id/posts
  #
  # This is accepting the post data when creating a new post and saves the post into db
  def create
    if (@post = Post.create(params[:post]) { |p| p.user_id = params[:user_id].to_i }) && @post.valid?
      flash.now[:notice] = 'Post has been created sccessfully'
      render :show
    else
      flash.now[:alert] = 'Cannot create post'
      render :new, :status => :unprocessable_entity
    end
  end

  # GET /users/:user_id/posts
  #
  # Returns all the posts of the user defined
  def index
    user = User.find(params[:user_id])
    @posts = user.posts.order("created_at desc")
  end

  # GET /users/:user_id/posts/:id
  #
  def show
    @post = Post.find(params[:id])
  end

  # GET /posts?limit=X
  #
  # Gets all posts from all users
  def index_all
    respond_to do |format|
      format.html {
        @posts = Post.index_all(params[:limit])
        render :index
      }
      format.rss {
        @posts = Post.feed_index_all(params[:limit])
        render :index, :layout => false
      }
    end
  end

  # DELETE /users/:user_id/posts/:id
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to request.env["HTTP_REFERER"] || user_posts_path(current_user), :notice => "Post deleted successfully"
  rescue ActiveRecord::ActiveRecordError => ex
    logger.error ex.message
    logger.error ex.backtrace

    flash.now[:alert] = "Cannot delete post, ex: #{ex.message}"
    render :show, :status => :unprocessable_entity
  end

  # GET /posts/more_posts?count=1 where count is the number of posts in view
  #
  # Returns the number of posts that are not displayed in the view.
  def more_posts
    count = 0
    count = params[:count].to_i if params[:count].present?
    current_count = Post.count
    @answer = 0
    @answer = current_count - count
    render :layout => false
  end

  ##############################

  protected

  def authorize
    # authorization check. User that is posting should be the one logged in
    unless current_user.present? && params[:user_id].to_i == current_user.id
      flash[:alert] = 'You do not have permssion to access this page'
      redirect_to login_path(:return_to => request.fullpath), :notice => "You have to log in"
    end
  end

end
