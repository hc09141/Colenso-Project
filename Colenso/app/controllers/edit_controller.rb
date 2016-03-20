include ApplicationHelper
class EditController < ApplicationController

  def index
      @path = params[:path]
      puts "INDEX #{@path}"
      @file = QueryBasex.new(nil, nil, @path, nil).display
  end

  def create
    puts "PATH #{@path}"
    QueryBasex.new(nil, nil, params[:path], params[:file]).editLetter
    redirect_to controller: 'search', action: 'index', mode: 'display', path: params[:path]
  end
end
