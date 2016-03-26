class Query < ActiveRecord::Base
   belongs_to :user, :inverse_of => :queries
end
