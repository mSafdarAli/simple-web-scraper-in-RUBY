require 'nokogiri'
require 'byebug'
require 'httparty'

def scrapper
	url = "http://www.hoovers.com/company-information/company-search.html"
	unparsed_page = HTTParty.get(url)
	parsed_page = Nokogiri::HTML(unparsed_page)
	names = Array.new
	company_names = parsed_page.css('tr') #26 rows
	page = 1
	per_page = company_names.count
	total = parsed_page.css('li.page.last_page').text.to_i
#	last_page = total 		#400 pages
	last_page = (total.to_f / per_page.to_f).round #15 pages
	while page <= last_page
		pagination_url = "http://www.hoovers.com/company-information/company-search.html?maxitems=25&page=#{page}"
		puts pagination_url
		puts "Page: #{page}"
		puts ''
		pagination_unparsed_page = HTTParty.get(pagination_url)
		pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
		pagination_company_names = pagination_parsed_page.css('tr')
		pagination_company_names.each do |company_name|
			name = {
				title: company_name.css('td.company_name').text,
				location: company_name.css('td.company_location').text,
				sales: company_name.css('td.company_sales'),
				profile: "http://www.hoovers.com" + company_name.css('a')[0].attributes["href"].value
			}
			names << name
			puts "Adeed #{name[:title]}"
			puts ""
			f = File.new('data.txt', 'a')
			f.write("#{name[:title]}")
			f.write("#{name[:location]}") 
			f.write("#{name[:sales]}")
			f.write("#{name[:profile]}") 
			f.close
		end
		page += 1
	end		
	byebug
end

scrapper	