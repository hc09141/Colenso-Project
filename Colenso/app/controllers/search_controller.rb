include ApplicationHelper

class SearchController < ApplicationController
  def index
    if params[:query]
      @data = params[:query]
      @searchType = params[:searchType]
      @basexQuery = QueryBasex.new(@data, @searchType, nil).call
    elsif params[:path]
      @file = QueryBasex.new(nil, nil, params[:path]).display
    end
  end
end
