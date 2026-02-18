# frozen_string_literal: true

class PagilaController < ApplicationController
  PER_PAGE = 20

  def index
    # Browse home: links to each table
  end

  def films
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @films = Film.order(:title).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @total = Film.count
  end

  def actors
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @actors = Actor.order(:last_name, :first_name).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @total = Actor.count
  end

  def categories
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @categories = Category.order(:name).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @total = Category.count
  end

  def customers
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @customers = Customer.order(:last_name, :first_name).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @total = Customer.count
  end
end
