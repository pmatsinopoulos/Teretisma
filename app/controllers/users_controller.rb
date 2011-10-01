class UsersController < ApplicationController

  # We will not authenticate the user that is trying to Sign Up (actions 'new' and 'create'),
  # or that is trying to see the list of registered users
  skip_before_filter :authenticate, :only => [:new, :create, :index]

  # GET /users/new
  #
  # This will feed the sign up form
  def new
    @user = User.new
  end

  # POST /users
  #
  # This is used to create a user in db. Handles posting of Sign Up form.
  def create
    @user = User.new(params[:user])
    if @user.save
      # we log him in and we redirect to root path
      log_user_in(@user)
      redirect_to root_path, :notice => "You have successfully signed up."
    else
      flash.now[:alert] = "Cannot sign you up. Sorry for that."
      render :new, :status => :unprocessable_entity
    end
  end

  # GET /users
  def index
    @users = User.order("full_name")
  end

end
