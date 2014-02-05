class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
    
  def after_sign_in_path_for(resource_or_scope)
    if current_user.has_role?(:superuser)
      admin_path
    else
      root_path
    end
  end
end
