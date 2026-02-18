# frozen_string_literal: true

class Language < ApplicationRecord
  self.table_name = "language"
  self.primary_key = "language_id"

  has_many :films
end
