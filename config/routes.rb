Openphin::Application.routes.draw do
  namespace :rollcall do 
    resources :graphing, :only => [:index]
    resources :alarm_query, :except => [:show,:new,:edit]
    resources :alarms, :controller => "alarm", :except => [:new,:show,:edit]
    resources :schools, :controller => "school", :only => [:index,:show]
    resources :nurse_assistant, :only => [:index,:destroy]
    resources :students, :controller => "student"
    resources :users, :controller => "user", :except => [:new, :create]
    resources :status, :controller => "status", :only => [:index]
    
    match "students/history", :to => "student#get_history", :as => :student_history
    match "nurse_assistant_options", :to => "nurse_assistant#get_options", :as => :get_nurse_assistant_options
    match "query_options(.:format)", :to => "graphing#get_options", :as => :get_query_options
    match "search_results", :to => "graphing#search_results", :as => :search_results
    match "get_neighbors", :to => "graphing#get_neighbors", :as => :get_neighbors
    match "export", :to => "graphing#export", :as => :export
    match "report", :to => "graphing#report", :as => :report
    match "alarm/:alarm_query_id", :to => "alarm#create", :as => :activate_alarm
    match "get_info", :to => "alarm#get_info", :as => :get_info
    match "get_gis", :to => "alarm#get_gis", :as => :get_gis
    match "get_schools", :to => "school#get_schools", :as => :get_schools
    match "get_school_data", :to => "school#get_school_data", :as => :get_school_data
    match "get_student_data", :to => "school#get_student_data", :as => :get_student_data
    match "get_user_school_districts", :to => "user#get_user_school_districts", :as => :get_user_school_districts
    match "unauthorized", :to => "rollcall_app#unauthorized", :as => :unauthorized
  end  
end
