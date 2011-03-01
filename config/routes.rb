ActionController::Routing::Routes.draw do |map|
  map.resources :adst, :controller => "rollcall/adst", :as => 'rollcall/adst'
  map.resources :save_query, :controller => "rollcall/saved_query", :as => "rollcall/save_query"
  map.resources :alarms, :controller => "rollcall/alarm", :as => "rollcall/alarms"
  map.resources :schools, :controller => "rollcall/school", :as => "rollcall/schools"
  map.get_query_options "/rollcall/query_options", :controller => "rollcall/adst", :action => "get_options"
  map.get_info "/rollcall/get_info", :controller => "rollcall/adst", :action => "get_info"
  map.export "/rollcall/export", :controller => "rollcall/adst", :action => "export"
  map.activate_alarm "/rollcall/alarm/:saved_query_id", :controller => "rollcall/alarm", :action => "create"
  map.get_schools "/rollcall/get_schools", :controller => "rollcall/school", :action => "get_schools"
end