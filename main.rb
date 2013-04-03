require 'json'
require 'open-uri'
require 'pp'
require 'date'
require './crawler'
require './storage'

#categories = [12001,12002,12003,12004,12005,12006,12007,12008,12010,12011,12012,12013,12014,12015,12016,12017,12018,12019,12020,12021,12022]

s = Nutte::Storage.new
categories = s.all_categories

categories.each { |cat|
	puts "crawling category #{cat.id} #{cat.name}"
	crawler = Nutte::Crawler.new
	crawler.crawl_category_by_id(cat.id)
	puts("we have " + crawler.gross_apps.count.to_s + " entries")

	allapps = crawler.gross_apps + crawler.paid_apps

	allapps.select { |app|
		app.artist.downcase.include?("szpilewski") or app.artist.downcase.include?("minyx")
	}.each { |app|
		PP.pp(app)
	}
}
