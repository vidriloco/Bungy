module MapHelper
  
  def trucks_stats_for(company)
    if @company.trucks.count == 1
      "<li>#{link_to I18n.t('app.views.map.trucks.stats.count.one'), nil}</li>".html_safe
    else
      "<li>#{link_to I18n.t('app.views.map.trucks.stats.count.many', :trucks => @company.trucks.count), nil}</li>".html_safe
    end
  end
end
