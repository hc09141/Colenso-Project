include ApplicationHelper
class EditController < ApplicationController

  def index
      @path = params[:path]
      @file = QueryBasex.new(nil, nil, @path, nil).display
  end

  def create
    result = QueryBasex.new(nil, nil, params[:path], params[:file]).editLetter
    redirect_to controller: 'browse', action: 'index', mode: 'display', path: params[:path] if result
    redirect_to controller: 'edit', action: 'index', mode: 'edit', path: params[:path], error: true if !result
  end
end
