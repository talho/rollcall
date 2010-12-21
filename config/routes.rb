ActionController::Routing::Routes.draw do |map|
  map.rollcall "/rollcall", :controller => "rollcall/rollcall"
  map.rollcall_summary_chart '/rollcall/chart/:timespan',:controller => "rollcall/rollcall", :action => 'summary_chart', :timespan => 7
  map.about_rollcall "/rollcall/about", :controller => "rollcall/rollcall", :action => "about"
  map.rollcall_schools "/rollcall/schools", :controller => "rollcall/schools", :action => "get"
  map.resources :rollcall_schools, :controller => "rollcall/schools", :as => 'rollcall/schools' do |school|
    school.chart '/chart/:timespan', :controller => "rollcall/schools", :action => "chart", :timespan => 7
  end
  map.resources :rollcall_school_districts, :member => {:school => :post}, :controller =>"rollcall/school_districts", :as => 'rollcall/school_districts'
  map.resources :adst, :controller => "rollcall/adst", :as => 'rollcall/adst'
  map.resources :save_query, :controller => "rollcall/saved_query", :as => "rollcall/save_query"
  
  map.get_query_options "/rollcall/query_options", :controller => "rollcall/adst", :action => "get_options"
  map.export "/rollcall/export", :controller => "rollcall/adst", :action => "export"
end