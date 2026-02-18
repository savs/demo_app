# frozen_string_literal: true

# Pagila sample DB: public.customer
class Customer < ApplicationRecord
  self.table_name = "customer"
  self.primary_key = "customer_id"

  belongs_to :address, optional: true
end
