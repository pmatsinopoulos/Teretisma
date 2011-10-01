class ApplicationController < ActionController::Base

  before_filter :authenticate

  protect_from_forgery

  helper_method :current_user

  # Returns the instance of the authenticated user. Otherwise, it returns nil.
  # This is a useful / helper method that will allow other modules to
  # get access to authenticated user object.
  #
  def current_user
    User.find_by_id(session[:user_id]) if session[:user_id].present?
  end

  def log_user_in (user)
    session[:user_id]= user.id unless user.nil?
  end

  ##################################################
  protected

  # This method will be called before every controller action on any controller
  # that derives from +ApplicationController+.
  # What it does is to authenticate the user, i.e. to find who the user that
  # is trying the action is. If he cannot find, he will redirect to login page
  # in order to ask user to enter username and password. As soon as the user
  # enters a valid username / password, he will be redirected back to
  # where he wanted to go (+request.fullpath+))
  # If authentication takes place, we are happy and return true.
  #
  def authenticate
    user = nil
    user = User.find_by_id(session[:user_id]) if session[:user_id].present?
    if !user.present?
      session[:user_id] = nil
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path(:return_to => request.fullpath)
    end
  end

end
