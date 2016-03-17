include ApplicationHelper

class BrowseController < ApplicationController

  def index
    @currentDirectory = "" if !params[:path]
    @currentDirectory = params[:path] if params[:path]
    @folders = QueryBasex.new(nil, nil, @currentDirectory).browse
    @file = QueryBasex.new(nil, nil, @currentDirectory).display if @currentDirectory.include?(".xml")
  end

end
