class InstantsController < ApplicationController
  include MainHelper
  
  before_filter :find_company
  
  def index
    @instants = Instant.all_for(@company)
    
    respond_to do |format|
      format.js
    end
  end
  
  def show
    @instant = GpsUnit.where(:identifier => params[:id]).first.instants.last
    
    respond_to do |format|
      format.js
    end
  end
end