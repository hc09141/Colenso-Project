class AddController < ApplicationController

  def index
    @currentDirectory = "" if !params[:path]
    @currentDirectory = params[:path] if params[:path]
    @folders = QueryBasex.new(nil, nil, @currentDirectory, nil).browse
    if params[:upload]
      @newLetter = params[:upload]
      QueryBasex.new(nil, nil, @currentDirectory, @newLetter).addLetter
    end
  end

  def upload
  end
end
