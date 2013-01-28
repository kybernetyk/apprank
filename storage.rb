require './app'
require './category'
require 'mysql2'

module Nutte
	class Crawl
		attr_accessor :id
		attr_accessor :timestamp
	end

	class Storage
		def connect
			if @is_connected
				return @db
			end	
			@db = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "apprank")
			@is_connected = true
		end

		def make_categories
			self.connect
      all_categories = [
      		{:id =>12001, :name => 'Business'},
      		{:id =>12002, :name => 'Developer Tools'},
      		{:id =>12003, :name => 'Education'},
      		{:id =>12004, :name => 'Entertainment'},
      		{:id =>12005, :name => 'Finance'},
      		{:id =>12006, :name => 'Games'},
      		{:id =>12007, :name => 'Health And Fitness'},
      		{:id =>12008, :name => 'Lifestyle'},
      		{:id =>12010, :name => 'Medical'},
      		{:id =>12011, :name => 'Music'},
      		{:id =>12012, :name => 'News'},
      		{:id =>12013, :name => 'Photography'},
      		{:id =>12014, :name => 'Productivity'},
      		{:id =>12015, :name => 'Reference'},
      		{:id =>12016, :name => 'Social Networking'},
      		{:id =>12017, :name => 'Sports'},
      		{:id =>12018, :name => 'Travel'},
      		{:id =>12019, :name => 'Utilities'},
      		{:id =>12020, :name => 'Video'},
      		{:id =>12021, :name => 'Weather'},
      		{:id =>12022, :name => 'Graphic And Design'}]
		  all_categories.each { |cat| 
		    id = cat[:id]
		    name = @db.escape(cat[:name])
        @db.query("insert into categories (id, name) values (#{id}, '#{name}') ON DUPLICATE KEY UPDATE id=id;")
		  }
		end
		
		def category_by_id(cat_id)
		  self.connect
		  res = @db.query("select * from categories where id = #{cat_id}").first
		  cat = Category.new
		  cat.name = res['name']
		  cat.id = res['id']
		  return cat
	  end
	  
	  def all_categories
	    self.connect
	    cats = @db.query("select * from categories;")
	    c = cats.map {|cat|
	      mycat = Category.new
	      mycat.name = cat['name']
	      mycat.id = cat['id']
	      mycat
	    }
	  	return c
  	end
  	
		def new_crawl
			self.connect
			@db.query('insert into crawls () values ();')
			res = @db.query('select * from crawls order by id desc;').first
			crawl = Crawl.new
			crawl.id = res['id']
			crawl.timestamp = res['timestamp'].to_datetime 
			return crawl
		end

		def store_crawl_results(crawl_id, crawl_date, paid_apps, gross_apps)
			self.connect
			puts "storing " << (paid_apps.count + gross_apps.count).to_s << " apps with crawl_id " << crawl_id.to_s
			paid_apps.each { |app| 
				name = @db.escape(app.name)
				desc = @db.escape(app.description)
				@db.query("INSERT INTO apps (id, author_id, category_id) VALUES (#{app.id}, #{app.artist_id}, #{app.category_id}) ON DUPLICATE KEY UPDATE id=id;")
				if @db.query("SELECT COUNT(*) FROM app_metadata where app_id = #{app.id} AND crawl_id = #{crawl_id};").first['COUNT(*)'].to_i == 0
					@db.query("INSERT INTO app_metadata (app_id, crawl_id, name, description) VALUES('#{app.id}', '#{crawl_id}', '#{name}', '#{desc}') ON DUPLICATE KEY UPDATE id=id;")
				end
				
				author_name = @db.escape(app.artist)
				@db.query("INSERT INTO authors (id, name) VALUES(#{app.artist_id}, '#{author_name}') ON DUPLICATE KEY UPDATE id=id");
				@db.query("INSERT INTO paid_ranks (app_id, crawl_id, rank) VALUES(#{app.id}, #{crawl_id}, #{app.rank});")

				currency = @db.escape(app.currency)
				if @db.query("SELECT COUNT(*) FROM prices  where app_id = #{app.id} AND crawl_id = #{crawl_id};").first['COUNT(*)'].to_i == 0
					@db.query("INSERT INTO prices (app_id, crawl_id, price, currency) VALUES(#{app.id}, #{crawl_id}, #{app.price.to_f}, '#{currency}')");
				end
			}
			gross_apps.each { |app| 
				name = @db.escape(app.name)
				desc = @db.escape(app.description)
				@db.query("INSERT INTO apps (id, author_id, category_id) VALUES (#{app.id}, #{app.artist_id}, #{app.category_id}) ON DUPLICATE KEY UPDATE id=id;")
				if @db.query("SELECT COUNT(*) FROM app_metadata where app_id = #{app.id} AND crawl_id = #{crawl_id};").first['COUNT(*)'].to_i == 0
					@db.query("INSERT INTO app_metadata (app_id, crawl_id, name, description) VALUES('#{app.id}', '#{crawl_id}', '#{name}', '#{desc}') ON DUPLICATE KEY UPDATE id=id;")
				end
				author_name = @db.escape(app.artist)
				@db.query("INSERT INTO authors (id, name) VALUES(#{app.artist_id}, '#{author_name}') ON DUPLICATE KEY UPDATE id=id");
				@db.query("INSERT INTO gross_ranks (app_id, crawl_id, rank) VALUES(#{app.id}, #{crawl_id}, #{app.rank});")
	
				currency = @db.escape(app.currency)
				if @db.query("SELECT COUNT(*) FROM prices  where app_id = #{app.id} AND crawl_id = #{crawl_id};").first['COUNT(*)'].to_i == 0
					@db.query("INSERT INTO prices (app_id, crawl_id, price, currency) VALUES(#{app.id}, #{crawl_id}, #{app.price.to_f}, '#{currency}')");
				end
			}
		end

	end


end
