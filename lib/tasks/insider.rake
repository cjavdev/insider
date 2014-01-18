#require 'net/ftp'
require 'debugger'
require 'rss'
require 'open-uri'

namespace :insider do
  desc "download from rss"
  task :rss => :environment do
    url = 'http://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&type=&company=&dateb=&owner=only&start=0&count=40&output=atom'
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      puts "Title: #{ feed.title }"
      p feed.entries.first
      feed.entries.each do |entry|
        doc = entry.link.href.gsub("-index.htm", ".txt")
        title = entry.title.to_s.gsub("<title>", "")
        cik = title[title.index("(")+1...title.index(")")]
        type = title[0...title.index(" -")].strip
        filed_on = entry.updated.to_s.gsub("<updated>", "").gsub("</updated>", "") 
        unless Document.find_by_link(doc)
          Document.create({
            :link => doc,
            :filed_on => entry.updated,
            :cik => cik,
            :filed_on => filed_on,
            :doc_type => type
          })
        end
        p doc
      end
    end
  end

  # desc "download indicies"
  # task :download_idx => :environment do
  #   1992.upto(2013) do |year|
  #     1.upto(4) do |qtr|
  #       `wget ftp://ftp.sec.gov/edgar/full-index/#{ year }/QTR#{ qtr }/company.zip`
  #       `unzip company.zip`
  #       `mv company.idx company.#{ year }.#{ qtr }.idx0`
  #       `rm company.zip`
  #     end
  #   end
  # end

  # desc "clean index headers"
  # task :clean_idx => :environment do
  #   1993.upto(2013) do |year|
  #     1.upto(4) do |qtr|
  #       puts "cleaning headers for company.#{ year }.#{ qtr }"
  #       header = true
  #       File.open("company.#{ year }.#{ qtr }.idx1", 'w') do |fout|
  #         File.open("company.#{ year }.#{ qtr }.idx0", 'r').each do |fin|
  #           fout.puts fin unless header
  #           header = false if fin.include?("------")
  #         end
  #       end
  #     end
  #   end
  #   1993.upto(2013) do |year|
  #     1.upto(4) do |qtr|
  #       puts "removing non insider filings for company.#{ year }.#{ qtr }.cln.idx"
  #       File.open("company.#{ year }.#{ qtr }.idx2", 'w') do |fout|
  #         File.open("company.#{ year }.#{ qtr }.idx1", 'r').each do |fin|
  #           next if fin.include?("EXPLORA INVESTIMENTOS GEST")
  #           begin
  #             if /(?<name>(\w+\s+)+)(?<type>4           |3           |4\/A           )(?<cik>\w+     )(?<filed_on>(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01]))(  )(?<link>[a-zA-Z0-9 \/ -.]*)/ =~ fin
  #               unless / S-4      / =~ fin
  #                 fout.puts fin
  #               end
  #             end
  #           rescue
  #             puts "error in this line"
  #             p fin
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  # desc "load indicies into db"
  # task :load_idx => :environment do
  #   r = Regexp.new('(?<name>(\w+\s+)+)(?<type>4           |3           |4\/A           )(?<cik>\w+     )(?<filed_on>(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01]))(  )(?<link>[a-zA-Z0-9 \/ -.]*)')
  #   doc_count = 0
  #   1996.upto(2013) do |year|
  #     1.upto(4) do |qtr|
  #       p [year, qtr]
  #       File.open("company.#{ year }.#{ qtr }.idx3", 'w') do |fout|
  #         File.open("company.#{ year }.#{ qtr }.idx2", 'r').each do |fin|
  #           m = r.match(fin)
  #           fout.puts "INSERT INTO documents (created_at, updated_at, company_name, type, cik, filed_on, link) VALUES (now(), now(), '#{ m[:name].strip }', '#{ m[:type].strip }','#{ m[:cik].strip }','#{ m[:filed_on].strip }','#{ m[:link].strip }');"
  #         end
  #       end
  #     end
  #   end
  #   puts "for f in *.idx3 ; do psql #{ config[Rails.env]['database'] } -f $f ; done"
  #   #`for f in *.idx3 ; do psql #{ config[Rails.env]["database"] } -f $f ; done`
  # end

  # task :download_filings => :environment do
  #   Dir.chdir(Rails.root.join("edgar"))
  #   ftp = Net::FTP.new("ftp.sec.gov")
  #   ftp.login
  #   1997.upto(2013) do |year|
  #     1.upto(4) do |qtr|
  #       ftp.chdir("/edgar/Feed/#{ year }/QTR#{ qtr }")
  #       days = ftp.nlst("*.gz")
  #       days.each_with_index do |d, x|
  #         puts "Downloading #{ x }/#{ days.count }: #{ d }"
  #         ftp.getbinaryfile(d) unless File.exists?(d)
  #       end
  #     end
  #   end
  # end
end
