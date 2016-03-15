include ApplicationHelper

class SearchController < ApplicationController
  def index
    if params[:query]
      @data = params[:query]
      @searchType = params[:searchType]
      @basexQuery = QueryBasex.new(@data, @searchType, nil).call
    end
  end
end
