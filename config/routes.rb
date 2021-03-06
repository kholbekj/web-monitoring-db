Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/session', to: 'users/sessions#validate_session'
  end

  namespace :api do
    namespace :v0 do
      resources :pages, only: [:index, :show], format: :json do
        resources :versions, only: [:index, :show, :create]
        resources :changes,
          # Allow :id to be ":from_uuid..:to_uuid" or just ":change_id"
          constraints: { id: /(?:[\w\-]*\.\.[\w\-]+)|(?:[^\.\/]+)/ },
          only: [:index, :show] do
            resources :annotations, only: [:index, :show, :create]
            member do
              get 'diff/:type', to: 'diff#show'
            end
        end
      end

      resources :versions, only: [:index, :show], format: :json
      resources :imports, only: [:create, :show], format: :json
    end
  end

  get 'admin', to: 'admin#index'
  post 'admin/invite'
  get 'admin/invite', to: redirect('admin')
  delete 'admin/cancel_invitation'
  post 'admin/cancel_invitation'
  delete 'admin/destroy_user'
  post 'admin/destroy_user'
end
