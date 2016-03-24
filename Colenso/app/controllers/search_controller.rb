include ApplicationHelper

class SearchController < ApplicationController
  #before_action :require_login


  def index
    if params[:query]
        @data = params[:query]
        @searchType = params[:searchType]
        @basexQuery = QueryBasex.new(@data, @searchType, nil, nil).call
        Query.create(content: @data)
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
