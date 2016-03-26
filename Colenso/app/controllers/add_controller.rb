include ApplicationHelper
class AddController < ApplicationController

  def index
    if !params[:stage]
      @currentDirectory = "" if !params[:path]
      @currentDirectory = params[:path] if params[:path]
      @folders = QueryBasex.new(nil, nil, @currentDirectory, nil).browse
    end
 end

  def create
    byebug
    if params[:stage] == 'add'
      @newLetter = params[:upload].original_filename
      @input = params[:upload].read
      byebug
      QueryBasex.new(@input, nil, params[:path], @newLetter).addLetter
      byebug
    end
    redirect_to action: 'index', stage: params[:stage], path: params[:path], uploadName: params[:upload].original_filename
  end
end
