# frozen_string_literal: true

class Address < ApplicationRecord
  self.table_name = "address"
  self.primary_key = "address_id"
end
