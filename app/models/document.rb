class Document < ActiveRecord::Base
  attr_accessible :cik, :company_name, :filed_on, :link, :type
end
