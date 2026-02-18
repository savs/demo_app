# frozen_string_literal: true

class FilmCategory < ApplicationRecord
  self.table_name = "film_category"
  self.primary_key = nil

  belongs_to :film
  belongs_to :category
end
