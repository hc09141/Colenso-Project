include ApplicationHelper

class BrowseController < ApplicationController

  def index
    @currentDirectory = "" if !params[:path]
    @currentDirectory = params[:path] if params[:path]
    @folders = QueryBasex.new(nil, nil, @currentDirectory, nil).browse
    @file = QueryBasex.new(nil, nil, @currentDirectory, nil).display if @currentDirectory.include?(".xml")
    puts "FILE: #{@file}"
  end

  def create
    @file = QueryBasex.new(nil, nil, params[:path], nil).display
    send_data @file, filename: "#{params[:path].split('/').last}"
  end

end
