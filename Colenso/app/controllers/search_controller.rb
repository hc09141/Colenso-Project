include ApplicationHelper

class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    if (params[:query]  && !params[:query].empty?) || (params[:xquery] && !params[:xquery].empty?)
      @data = params[:query]
      @data ||= params[:xquery]
      @data = params[:xquery] if @data.empty?
      @searchType = params[:searchType]
      @searchType = 'Text' if !@searchType || @searchType.empty?
      query = current_user.queries.create(content: @data, searchType: @searchType, parentQuery_id: params[:parent]) if params[:parent] && params[:commit] == "Nested Search"
      query = current_user.queries.create(content: @data, searchType: @searchType) if !params[:parent] || params[:commit] == "New Search"
      @queries = getNestQueries(query, [])
      @searchTime = Time.now
      @basexQuery = QueryBasex.new(@queries, @searchType, nil, nil).call
      @parentID = query.id
      @resultsCount = @basexQuery.count / 4 if @basexQuery
      @searchTime = Time.now - @searchTime
    elsif params[:path]
      @file = QueryBasex.new(nil, nil, params[:path], nil).display
    end
  end

  def getNestQueries(query, queries)
    queries << query.content
    queries << query.searchType
    return queries unless query.parentQuery_id
    getNestQueries(Query.find(query.parentQuery_id), queries)
  end

  def create
    if params[:mode] == 'download'
      queries = getNestQueries(current_user.queries.last, [])
      file = QueryBasex.new(queries, params[:searchType], nil, nil).bulkDownload
      send_file file.path, type: 'application/zip', disposition: 'attachment', filename: 'search-results.zip'
      file.close
    elsif params[:mode] == 'delete'
      QueryBasex.new(nil, nil, params[:path], nil).delete
      redirect_to controller: 'browse', mode: 'display', path: params[:path].rpartition('/').first
    else
      @file = QueryBasex.new(nil, nil, params[:path], nil).display
      send_data @file, filename: "#{params[:path].split('/').last}"
    end
  end
end
