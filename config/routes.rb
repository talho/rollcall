Openphin::Application.routes.draw do
  namespace :rollcall do 
    resources :adst, :only => [:index]
    resources :alarm_query, :except => [:show,:new,:edit]
    resources :alarms, :controller => "alarm", :except => [:new,:show,:edit]
    resources :schools, :controller => "school", :only => [:index,:show]
    resources :nurse_assistant, :only => [:index,:destroy]
    resources :students, :controller => "student"
    resources :rollcall_users, :controller => "user"
    
    match "/rollcall/students/history", :to => "student#get_history", :as => :student_history
    match "/rollcall/nurse_assistant_options", :to => "nurse_assistant#get_options", :as => :get_nurse_assistant_options
    match "/rollcall/query_options", :to => "adst#get_options", :as => :get_query_options
    match "/rollcall/export", :to => "adst#export", :as => :export
    match "/rollcall/report", :to => "adst#report", :as => :report
    match "/rollcall/alarm/:alarm_query_id", :to => "alarm#create", :as => :activate_alarm
    match "/rollcall/get_info", :to => "alarm#get_info", :as => :get_info
    match "/rollcall/get_schools", :to => "school#get_schools", :as => :get_schools
    match "/rollcall/get_school_data", :to => "school#get_school_data", :as => :get_school_data
    match "/rollcall/get_student_data", :to => "school#get_student_data", :as => :get_student_data
    match "rollcall/get_user_school_districts", :to => "user#get_user_school_districts", :as => :get_user_school_districts
    match "/rollcall/unauthorized", :to => "rollcall_app#unauthorized", :as => :unauthorized
  end  
end
