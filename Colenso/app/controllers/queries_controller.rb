class QueriesController < ApplicationController
  def index
    @queries = Query.all
    @users = User.all
    @username = current_user.id
  end
end
