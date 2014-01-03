class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :company_name
      t.string :type
      t.string :cik
      t.string :filed_on
      t.string :link

      t.timestamps
    end
  end
end
