namespace :insider do
  desc "download indicies"
  task :download_idx => :environment do
    1992.upto(2013) do |year|
      1.upto(4) do |qtr|
        `wget ftp://ftp.sec.gov/edgar/full-index/#{ year }/QTR#{ qtr }/company.zip`
        `unzip company.zip`
        `mv company.idx company.#{ year }.#{ qtr }.idx0`
        `rm company.zip`
      end
    end
  end

  desc "clean index headers"
  task :clean_idx => :environment do
    1993.upto(2013) do |year|
      1.upto(4) do |qtr|
        puts "cleaning headers for company.#{ year }.#{ qtr }"
        header = true
        File.open("company.#{ year }.#{ qtr }.idx1", 'w') do |fout|
          File.open("company.#{ year }.#{ qtr }.idx0", 'r').each do |fin|
            fout.puts fin unless header
            header = false if fin.include?("------")
          end
        end
      end
    end
    1993.upto(2013) do |year|
      1.upto(4) do |qtr|
        puts "removing non insider filings for company.#{ year }.#{ qtr }.cln.idx"
        File.open("company.#{ year }.#{ qtr }.idx2", 'w') do |fout|
          File.open("company.#{ year }.#{ qtr }.idx1", 'r').each do |fin|
            next if fin.include?("EXPLORA INVESTIMENTOS GEST")
            begin
              if /(?<name>(\w+\s+)+)(?<type>4           |3           |4\/A           )(?<cik>\w+     )(?<filed_on>(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01]))(  )(?<link>[a-zA-Z0-9 \/ -.]*)/ =~ fin
                unless / S-4      / =~ fin
                  fout.puts fin
                end
              end
            rescue
              puts "error in this line"
              p fin
            end
          end
        end
      end
    end
  end

  desc "load indicies into db"
  task :load_idx => :environment do
    r = Regexp.new('(?<name>(\w+\s+)+)(?<type>4           |3           |4\/A           )(?<cik>\w+     )(?<filed_on>(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01]))(  )(?<link>[a-zA-Z0-9 \/ -.]*)')
    doc_count = 0
    1996.upto(2013) do |year|
      1.upto(4) do |qtr|
        p [year, qtr]
        File.open("company.#{ year }.#{ qtr }.idx3", 'w') do |fout|
          File.open("company.#{ year }.#{ qtr }.idx2", 'r').each do |fin|
            m = r.match(fin)
            fout.puts "INSERT INTO documents (created_at, updated_at, company_name, type, cik, filed_on, link) VALUES (now(), now(), '#{ m[:name].strip }', '#{ m[:type].strip }','#{ m[:cik].strip }','#{ m[:filed_on].strip }','#{ m[:link].strip }');"
          end
        end
      end
    end
    puts "for f in *.idx3 ; do psql #{ config[Rails.env]['database'] } -f $f ; done"
    #`for f in *.idx3 ; do psql #{ config[Rails.env]["database"] } -f $f ; done`
  end

  task :download_filings => :environment do
     
  end
end
