ActionController::Routing::Routes.draw do |map|
  map.resources :adst, :controller => "rollcall/adst", :as => 'rollcall/adst'
  map.resources :save_query, :controller => "rollcall/saved_query", :as => "rollcall/save_query"
  map.resources :alarms, :controller => "rollcall/alarm", :as => "rollcall/alarms"
  map.get_query_options "/rollcall/query_options", :controller => "rollcall/adst", :action => "get_options"
  map.export "/rollcall/export", :controller => "rollcall/adst", :action => "export"
end