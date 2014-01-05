class ChangeHandledToDefaultFalseDocuments < ActiveRecord::Migration
  def up
    remove_column :documents, :handled
    add_column :documents, :handled, :boolean, :default => false
  end
end
