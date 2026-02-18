Rails.application.routes.draw do
  root "home#index"

  get "pagila", to: "pagila#index", as: :pagila
  get "pagila/films", to: "pagila#films", as: :pagila_films
  get "pagila/actors", to: "pagila#actors", as: :pagila_actors
  get "pagila/categories", to: "pagila#categories", as: :pagila_categories
  get "pagila/customers", to: "pagila#customers", as: :pagila_customers
end
