class SessionsController < ApplicationController

  # We will not authenticate the user that is trying to login (actions 'new' and 'create'),
  # or that is loggin out (action 'destroy')
  skip_before_filter :authenticate, :only => [:new, :create, :destroy]

  # GET /login
  #
  # Invoked when user requests the page to login
  def new
  end

  # Delete /logout
  #
  # Invoked when user wants to logout
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  # POST /login
  #
  # Invoked when user posts data over the page to login
  def create
    if ( user = User.find_by_username(params[:username]) ) && user.password == params[:password]
      log_user_in(user)
      redirect_to params[:return_to] || root_path, :notice => "You have successfully logged in"
    else
      flash.now[:alert] = "Invalid credentials. Please, try again"
      render :new, :status => :forbidden
    end
  end

end
