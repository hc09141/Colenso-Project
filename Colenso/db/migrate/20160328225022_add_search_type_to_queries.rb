class AddSearchTypeToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :searchType, :string
  end
end
