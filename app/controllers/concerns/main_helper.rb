module MainHelper
  protected
  
  def find_company
    if user_signed_in? && !current_user.has_role?(:superuser)
      @user = current_user
      @company = current_user.company
    else
      redirect_to '/admin'
    end
  end
end