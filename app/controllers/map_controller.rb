class MapController < ApplicationController
  layout 'map_layout'
  
  before_filter :authenticate_user!, :except => [:heading]
  before_filter :find_company
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def heading
    @instants = Instant.all_for(@company)
    
    respond_to do |format|
      format.js
    end
  end
  
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
