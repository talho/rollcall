Rails.application.routes.draw do
  devise_for :users
  resources :graphing, :only => [:index]
  resources :alarm_query, :except => [:new,:edit]
  resources :alarms, :controller => "alarm", :except => [:new,:edit]
  resources :schools, :controller => "school", :only => [:index,:show]
  resources :nurse_assistant, :only => [:index,:destroy]
  resources :students, :controller => "student"
  resources :users, :controller => "user", :except => [:new, :create] do
    collection do
      get :available_school_districts
    end
    member do
      get :school_districts
      get :schools
    end
  end
  resources :status, :controller => "status", :only => [:index]
  resources :map, :controller => "map", :only => [:index]

  get "students/history", :to => "student#get_history", :as => :student_history
  get "nurse_assistant_options", :to => "nurse_assistant#get_options", :as => :get_nurse_assistant_options
  get "query_options(.:format)", :to => "graphing#get_options", :as => :get_query_options
  get "search_results", :to => "graphing#search_results", :as => :search_results
  get "get_neighbors", :to => "graphing#get_neighbors", :as => :get_neighbors
  get "export", :to => "graphing#export", :as => :export
  get "report", :to => "graphing#report", :as => :report
  get "/alarm_query/toggle/:id", :to => "alarm_query#toggle", :as => :toggle
  get "alarm/:alarm_query_id", :to => "alarm#create", :as => :activate_alarm
  get "get_info", :to => "alarm#get_info", :as => :get_info
  get "get_gis", :to => "alarm#get_gis", :as => :get_gis
  get "get_schools", :to => "school#get_schools", :as => :get_schools
  get "get_school_data", :to => "school#get_school_data", :as => :get_school_data
  get "get_student_data", :to => "school#get_student_data", :as => :get_student_data
  get "unauthorized", :to => "rollcall_app#unauthorized", :as => :unauthorized
end
