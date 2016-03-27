class AddNestedColumnToQuery < ActiveRecord::Migration
  def change
    add_reference :queries, :parentQuery, index: true, foreign_key: true
  end
end
