class ChangeFiledOnDocuments < ActiveRecord::Migration
  def up
    remove_column :documents, :filed_on
    add_column :documents, :filed_on, :datetime, :null => false
    remove_column :documents, :type
    add_column :documents, :type, :string, :limit => 7, :null => false
    remove_column :documents, :cik
    add_column :documents, :cik, :string, :limit => 31, :null => false
  end
end
