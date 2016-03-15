include ApplicationHelper

class BrowseController < ApplicationController

  def index
    @currentDirectory = ""
    @folders = QueryBasex.new(nil, nil, @currentDirectory).list
  end

end
