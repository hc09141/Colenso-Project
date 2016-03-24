class QueriesController < ApplicationController
  def index
    @queries = Query.all
  end
end
