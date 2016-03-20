include ApplicationHelper

class SearchController < ApplicationController
  def index
    if params[:query]
      @data = params[:query]
      @searchType = params[:searchType]
      @basexQuery = QueryBasex.new(@data, @searchType, nil, nil).call
    elsif params[:path]
      @file = QueryBasex.new(nil, nil, params[:path], nil).display
    end
  end

  def create
    send_data @file, filename: "#{params[:path].split('/').last}"
  end

end
