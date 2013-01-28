require 'json'
require 'open-uri'
require 'pp'
require 'date'
require './crawler'

categories = [12001,12002,12003,12004,12005,12006,12007,12008,12010,12011,12012,12013,12014,12015,12016,12017,12018,12019,12020,12021,12022]

categories.each { |cat|
	puts "crawling category #{cat}"
	crawler = Nutte::Crawler.new
	crawler.crawl_category_by_id(cat.to_i)
	puts("we have " + crawler.gross_apps.count.to_s + " entries")

	crawler.gross_apps.select { |app|
		app.artist.downcase.include?("szpilewski")
	}.each { |app|
		PP.pp(app)
	}
}
