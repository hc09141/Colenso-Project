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
    if params[:mode] == 'download'
      QueryBasex.new(params[:query], params[:searchType], nil, nil).bulkDownload
      redirect_to action: 'index', query: params[:query], searchType: params[:searchType]
    else
      send_data @file, filename: "#{params[:path].split('/').last}"
    end
  end

end
