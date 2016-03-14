include ApplicationHelper

class SearchController < ApplicationController
  def index
    if params[:query]
      @data = params[:query]
      @basexQuery = QueryBasex.new(@data).call
      puts @basexQuery
    end
  end
end
