ActionController::Routing::Routes.draw do |map|
  map.rollcall "/rollcall", :controller => "rollcall/rollcall"
  map.rollcall_summary_chart '/rollcall/chart/:timespan',:controller => "rollcall/rollcall", :action => 'summary_chart', :timespan => 7
  map.about_rollcall "/rollcall/about", :controller => "rollcall/rollcall", :action => "about"
  map.resources :schools, :controller => "rollcall/schools" do |school|
    school.chart '/chart/:timespan', :controller => "rollcall/schools", :action => "chart", :timespan => 7
  end
  map.resources :school_districts, :member => {:school => :post}, :controller =>"rollcall/school_districts"
end
