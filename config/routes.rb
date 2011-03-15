ActionController::Routing::Routes.draw do |map|
  map.resources :adst, :controller => "rollcall/adst", :as => 'rollcall/adst'
  map.resources :alarm_query, :controller => "rollcall/alarm_query", :as => "rollcall/alarm_query"
  map.resources :alarms, :controller => "rollcall/alarm", :as => "rollcall/alarms"
  map.resources :schools, :controller => "rollcall/school", :as => "rollcall/schools"
  map.get_schools_for_combobox "/rollcall/get_schools_for_combobox", :controller => "rollcall/school", :action => "get_schools_for_combobox"
  map.get_query_options "/rollcall/query_options", :controller => "rollcall/adst", :action => "get_options"
  map.get_info "/rollcall/get_info", :controller => "rollcall/adst", :action => "get_info"
  map.export "/rollcall/export", :controller => "rollcall/adst", :action => "export"
  map.activate_alarm "/rollcall/alarm/:alarm_query_id", :controller => "rollcall/alarm", :action => "create"
  map.get_schools "/rollcall/get_schools", :controller => "rollcall/school", :action => "get_schools"
  map.get_school_data "/rollcall/get_school_data", :controller => "rollcall/school", :action => "get_school_data"
end
