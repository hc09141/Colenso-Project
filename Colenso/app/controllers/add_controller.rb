class AddController < ApplicationController

  def index
    @currentDirectory = "" if !params[:path]
    @currentDirectory = params[:path] if params[:path]
    @folders = QueryBasex.new(nil, nil, @currentDirectory, nil).browse
    @newLetter = params[:upload] if params[:upload]
  end

  def upload
  end
end
