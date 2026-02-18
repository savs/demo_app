# frozen_string_literal: true

# Pagila sample DB: public.category
class Category < ApplicationRecord
  self.table_name = "category"
  self.primary_key = "category_id"

  has_many :film_categories
  has_many :films, through: :film_categories
end
