include ApplicationHelper

class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query] && !params[:query].empty?
      byebug
        @data = params[:query]
        @searchType = params[:searchType]
        @searchType = 'Text' if !@searchType || @searchType.empty?
        @searchTime = Time.now
        byebug
        @basexQuery = QueryBasex.new(@data, @searchType, nil, nil).call
        byebug
        current_user.queries.create(content: @data)
        @resultsCount = @basexQuery.count / 3 if @basexQuery
        @searchTime = Time.now - @searchTime
    elsif params[:path]
      @file = QueryBasex.new(nil, nil, params[:path], nil).display
      byebug
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
