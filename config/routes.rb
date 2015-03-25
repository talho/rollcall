Rails.application.routes.draw do

  root 'main#index'

  resources :school_districts do
    resources :schools, except: [:index] do
      resources :school_users, only: [:new, :create, :destroy]
    end
    resources :school_district_users, only: [:new, :create, :destroy]
  end

  resources :school_daily_infos, only: [:index, :create]
  resources :student_daily_infos, except: [:show]
  resources :graphing, :only => [:index] do
    member do
      get :school
      get :school_district
    end
  end

  resource :alarm, only: [:show, :update]

  devise_for :users
end
