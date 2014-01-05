class AddFetchedToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :fetched, :boolean, :default => false
  end
end
