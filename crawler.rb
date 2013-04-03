require './app'
require './storage'
module Nutte
 class Crawler
	 attr_accessor :gross_apps
	 attr_accessor :paid_apps

  	:private
		def get_artist_id(artist_url)
			sub = artist_url.split('/').last.to_s
			sub.split('?').first.split('id').last
		end

		def make_date(date_string)
			DateTime.parse(date_string)
		end

  	def make_apps(entries)
  		entries.each_with_index.map { |ent, index|
    		app = App.new
    		{:name => ent['im:name']['label'],
    		 :price => ent['im:price']['attributes']['amount'],
    		 :currency => ent['im:price']['attributes']['currency'],
    		 :release_date => self.make_date(ent['im:releaseDate']['label']),
    		 :category_id => ent['category']['attributes']['im:id'],
    		 :category => ent['category']['attributes']['label'],
    		 :rank => index+1,
    		 :description => ent['summary']['label'],
    		 :id => ent['id']['attributes']['im:id'],
    		 :artist => ent['im:artist']['label'],
    		 :artist_id => self.get_artist_id(ent['im:artist']['attributes']['href']),
    		 :crawl_date => @crawl_date,
				 :crawl_id => @crawl_id
    		}.each {|k, v|
    			app.instance_variable_set("@#{k}", v)
    		}
  		  app
  		}
  	end

		def get_gross_entries(category_id)
  	  url = "https://itunes.apple.com/us/rss/topgrossingmacapps/limit=300/genre=" << category_id.to_s << "/json"
  		jsondata = open(url).read()
  		parsed = JSON.parse(jsondata)
  		parsed['feed']['entry']
  	end

		def get_paid_entries(category_id)
  	  url = "https://itunes.apple.com/us/rss/toppaidmacapps/limit=300/genre=" << category_id.to_s << "/json"
  		jsondata = open(url).read()
  		parsed = JSON.parse(jsondata)
  		parsed['feed']['entry']
  	end

  	:public
  	def crawl_category_by_id(category_id)
			storage = Storage.new

  		crawl = storage.new_crawl(category_id)
			@crawl_id = crawl.id
			@crawl_date = crawl.timestamp

  		paid_entries = get_paid_entries(category_id)

  		@paid_apps = make_apps(paid_entries)
			gross_entries = get_gross_entries(category_id)
			@gross_apps = make_apps(gross_entries)

			storage.store_crawl_results(@crawl_id, @crawl_date, @paid_apps, @gross_apps)
  	end
  end
end
