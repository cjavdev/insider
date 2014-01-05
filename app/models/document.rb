class Document < ActiveRecord::Base
  attr_accessible :cik, :company_name, :filed_on, :link, :type, :handled
  validates_uniqueness_of :link

  def self.not_downloaded
    where(:handled => false)
  end

  def download
    `wget ftp://ftp.sec.gov/#{ self.link }`
    `mv #{ file_name } #{ file_name }.rawform`
    self.fetched = true
    self.save!
  end

  def file_name
    File.basename(self.link)
  end
end
