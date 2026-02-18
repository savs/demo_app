# frozen_string_literal: true

class PagilaController < ApplicationController
  PER_PAGE = 20

  # DEMO/TEST: probability (0.0–1.0) that a request runs an extra slow or locking query
  SLOW_QUERY_CHANCE = 0.12
  LOCK_QUERY_CHANCE = 0.04

  def index
    # Browse home: links to each table
  end

  def films
    maybe_run_slow_or_lock
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @films = Film.order(:title).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @total = Film.count
  end

  def actors
    maybe_run_slow_or_lock
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
    maybe_run_slow_or_lock
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @customers = Customer.order(:last_name, :first_name).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @total = Customer.count
  end

  private

  def maybe_run_slow_or_lock
    r = rand
    if r < LOCK_QUERY_CHANCE
      run_lock(3 + rand(3)) # 3–5 second lock
    elsif r < LOCK_QUERY_CHANCE + SLOW_QUERY_CHANCE
      run_heavy
    end
  end

  def run_lock(seconds)
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("LOCK TABLE film IN ACCESS EXCLUSIVE MODE")
      ActiveRecord::Base.connection.execute("SELECT pg_sleep(#{seconds.to_i})")
    end
  end

  def run_heavy
    sql = <<~SQL.squish
      SELECT COUNT(*) FROM (
        SELECT 1
        FROM film f1
        CROSS JOIN film f2
        CROSS JOIN film_actor fa
        WHERE f1.film_id = fa.film_id AND f2.film_id = fa.film_id
      ) t
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end
end
