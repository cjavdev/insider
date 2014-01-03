namespace :insider do
  desc "download indicies"
  task :download_idx => :environment do
    1992.upto(2013) do |year|
      1.upto(4) do |qtr|
        `wget ftp://ftp.sec.gov/edgar/full-index/#{ year }/QTR#{ qtr }/company.zip`
        `unzip company.zip`
        `mv company.idx company.#{ year }.#{ qtr }.idx`
        `rm company.zip`
      end
    end
  end

  desc "clean index headers"
  task :clean_idx => :environment do
    1993.upto(2013) do |year|
      1.upto(4) do |qtr|
        puts "cleaning headers for company.#{ year }.#{ qtr }.cln.idx"
        header = true
        File.open("company.#{ year }.#{ qtr }.cln.idx", 'w') do |fout|
          File.open("company.#{ year }.#{ qtr }.idx", 'r').each do |fin|
            fout.puts fin unless header
            header = false if fin.include?("------")
          end
        end
      end
    end
    1993.upto(2013) do |year|
      1.upto(4) do |qtr|
        puts "removing non insider filings for company.#{ year }.#{ qtr }.cln.idx"
        File.open("company.#{ year }.#{ qtr }.cln2.idx", 'w') do |fout|
          File.open("company.#{ year }.#{ qtr }.cln.idx", 'r').each do |fin|
            next if fin.include?("EXPLORA INVESTIMENTOS GEST")
            begin
              if /4         |3           |4\/A           / =~ fin
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
    1994.upto(1994) do |year|
      4.upto(4) do |qtr|
        File.open("/Users/w1zeman1p/Documents/github/ftpsec/insider_app/lib/tasks/company.#{ year }.#{ qtr }.cln2.idx", 'r').each do |fin|
          mdata = r.match(fin)
          p mdata
        end
      end
    end
  end
end
