class MapController < ApplicationController
  include MainHelper
  
  layout 'map_layout'
  
  before_filter :authenticate_user!
  before_filter :find_company
  
  def index
    respond_to do |format|
      format.html
    end
  end
end
