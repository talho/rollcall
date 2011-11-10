ActionController::Routing::Routes.draw do |map|
  map.resources :adst, :controller => "rollcall/adst", :as => 'rollcall/adst'
  map.resources :alarm_query, :controller => "rollcall/alarm_query", :as => "rollcall/alarm_query"
  map.resources :alarms, :controller => "rollcall/alarm", :as => "rollcall/alarms"
  map.resources :schools, :controller => "rollcall/school", :as => "rollcall/schools"
  map.resources :nurse_assistant, :controller => "rollcall/nurse_assistant", :as => "rollcall/nurse_assistant"
  map.resources :students, :controller => "rollcall/student", :as => "rollcall/students"
  map.resources :rollcall_users, :controller => "rollcall/user", :as => "rollcall/users"

  map.student_history "/rollcall/students/history", :controller => "rollcall/student", :action => "get_history" 
  map.get_nurse_assistant_options "/rollcall/nurse_assistant_options", :controller => "rollcall/nurse_assistant", :action => "get_options"
  map.get_query_options "/rollcall/query_options", :controller => "rollcall/adst", :action => "get_options"
  map.export "/rollcall/export", :controller => "rollcall/adst", :action => "export"
  map.report "/rollcall/report", :controller => "rollcall/adst", :action => "report"
  map.activate_alarm "/rollcall/alarm/:alarm_query_id", :controller => "rollcall/alarm", :action => "create"
  map.get_info "/rollcall/get_info", :controller => "rollcall/alarm", :action => "get_info"  
  map.get_schools "/rollcall/get_schools", :controller => "rollcall/school", :action => "get_schools"
  map.get_school_data "/rollcall/get_school_data", :controller => "rollcall/school", :action => "get_school_data"
  map.get_student_data "/rollcall/get_student_data", :controller => "rollcall/school", :action => "get_student_data"
  map.get_user_school_districts "rollcall/get_user_school_districts", :controller => "rollcall/user", :action => "get_user_school_districts"
  map.unauthorized "/rollcall/unauthorized", :controller => "rollcall/rollcall_app",:action => "unauthorized"
end
