include ApplicationHelper
class AddController < ApplicationController

  def index
    @currentDirectory = "" if !params[:path]
    @currentDirectory = params[:path] if params[:path]
    @folders = QueryBasex.new(nil, nil, @currentDirectory, nil).browse

 end

  def create
    newLetter = params[:upload].original_filename
    input = params[:upload].read
    QueryBasex.new(input, nil, @currentDirectory, newLetter).addLetter
    redirect_to action: 'index'
  end
end
