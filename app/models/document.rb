require 'net/ftp'

class Document < ActiveRecord::Base
  attr_accessible :cik, :company_name, :filed_on, :link, :type, :handled
  validates_uniqueness_of :link

  def self.not_downloaded
    where(:handled => false)
  end

  def download
    setup_dir unless dir_setup?
    download_all_filings unless downloaded?
    self.fetched = true
    self.save!
  end

  def dir_setup?
    File.directory?(Rails.root.join(dir))
  end

  def downloaded?
    File.exists?(Rails.root.join(link))
  end

  def setup_dir
    x = 0
    begin
      puts "Creating: #{ Rails.root.join(dir) }"
      Dir.mkdir(Rails.root.join(dir))
    rescue  => error
      p error
      ["edgar", "edgar/data"].each do |d|
        unless File.directory?(Rails.root.join(d))
          puts "Creating: #{ Rails.root.join(d) }"
          Dir.mkdir(Rails.root.join(d))
        end
      end
      x += 1
      retry if x <= 3
    end
    puts "Created: #{ Rails.root.join(dir) }"
  end

  def download_all_filings
    ftp = Net::FTP::new("ftp.sec.gov")
    ftp.login
    ftp.chdir(dir)
    Dir.chdir(Rails.root.join(dir))
    fileList = ftp.nlst('*.txt')
    t = fileList.count
    puts "Downloading #{ fileList.count } filings in: #{ dir }"
    fileList.each_with_index do |file, x|
      puts "Downloading #{ x }/#{ t }: #{ file }"
      ftp.getbinaryfile(file) unless File.exists?(file)
    end
    ftp.close
    puts "Downloaded all filings in: #{ dir }"
  end

  def dir
    File.dirname(self.link)
  end

  def file_name
    File.basename(self.link)
  end

  def xml_format_file_name
    file_name + ".xmlform"
  end

  def fetched_path
    Rails.root.join(dir) + file_name
  end

  def xml_only_path
    fetched_path.to_s + ".xml"
  end

  def extract_xml
    raw = File.read(fetched_path)
    r = /(<XML>)(?<document>\w*\s*.*)(<\/XML>)/m
    m = r.match(raw)
    unless m.nil?
      File.write(xml_only_path, m[:document])
      self.handled = true
      File.delete(fetched_path)
      self.save!
    end
    nil
  end
end
