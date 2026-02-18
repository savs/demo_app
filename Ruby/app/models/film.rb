# frozen_string_literal: true

# Pagila sample DB: public.film
class Film < ApplicationRecord
  self.table_name = "film"
  self.primary_key = "film_id"
  self.ignored_columns = ["fulltext"]

  has_many :film_actors
  has_many :actors, through: :film_actors
  has_many :film_categories
  has_many :categories, through: :film_categories
  belongs_to :language, class_name: "Language", foreign_key: "language_id", optional: true
end
