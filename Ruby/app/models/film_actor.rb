# frozen_string_literal: true

class FilmActor < ApplicationRecord
  self.table_name = "film_actor"
  self.primary_key = nil

  belongs_to :film
  belongs_to :actor
end
