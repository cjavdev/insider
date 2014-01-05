class AddHandledToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :handled, :boolean
  end
end
