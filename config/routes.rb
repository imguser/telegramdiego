# For details on the DSL available within this file, see
# http://guides.rubyonrails.org/routing.html
require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount Sidekiq::Web => '/sidekiq'

  telegram_webhook TelegramController, :default

  root to: 'devise/sessions#new'
end
