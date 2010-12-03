ActionController::Routing::Routes.draw do |map|
  map.rollcall "/rollcall", :controller => "rollcall/rollcall"
  map.rollcall_summary_chart '/rollcall/chart/:timespan',:controller => "rollcall/rollcall", :action => 'summary_chart', :timespan => 7
  map.about_rollcall "/rollcall/about", :controller => "rollcall/rollcall", :action => "about"
  map.rollcall_schools "/rollcall/schools", :controller => "rollcall/schools", :action => "get"
  map.resources :rollcall_schools, :controller => "rollcall/schools" do |school|
    school.chart '/chart/:timespan', :controller => "rollcall/schools", :action => "chart", :timespan => 7
  end
  map.resources :rollcall_school_districts, :member => {:school => :post}, :controller =>"rollcall/school_districts"

  map.resources :rollcall_queries, :controller => "rollcall/queries"
  map.get_query_options "/rollcall/query_options", :controller => "rollcall/queries", :action => "get_options"
  map.search "/rollcall/adst", :controller => "rollcall/queries", :action => "search"
end