include ApplicationHelper

class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query] && !params[:query].empty?
        @data = params[:query]
        @searchType = params[:searchType]
        @searchTime = Time.now
        @basexQuery = QueryBasex.new(@data, @searchType, nil, nil).call
        Query.create(content: @data)
        @resultsCount = @basexQuery.count / 3
        @searchTime = Time.now - @searchTime
    elsif params[:path]
      @file = QueryBasex.new(nil, nil, params[:path], nil).display
    end
  end

  def create
    if params[:mode] == 'download'
      file = QueryBasex.new(params[:query], params[:searchType], nil, nil).bulkDownload
      send_file file.path, type: 'application/zip', disposition: 'attachment', filename: 'search-results.zip'
      file.close
    else
      send_data @file, filename: "#{params[:path].split('/').last}"
    end
  end

end
