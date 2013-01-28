require './app'
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
		
		def new_crawl
			self.connect
			@db.query('insert into crawls () values ();')
			res = @db.query('select * from crawls order by id desc;').first
			crawl = Crawl.new
			crawl.id = res['id']
			crawl.timestamp = res['timestamp'].to_datetime 
			crawl
		end

		def store_crawl_results(crawl_id, crawl_date, paid_apps, gross_apps)
			self.connect
			puts "storing " << (paid_apps.count + gross_apps.count).to_s << " apps with crawl_id " << crawl_id.to_s
			paid_apps.each { |app| 
				puts "storing paid: #{app.name} ..."
				name = @db.escape(app.name)
				desc = @db.escape(app.description)
				@db.query("INSERT INTO apps (id, author_id) VALUES (#{app.id}, #{app.artist_id}) ON DUPLICATE KEY UPDATE id=id;")
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
				puts "storing gross: #{app.name} ..."
				name = @db.escape(app.name)
				desc = @db.escape(app.description)
				@db.query("INSERT INTO apps (id, author_id) VALUES (#{app.id}, #{app.artist_id}) ON DUPLICATE KEY UPDATE id=id;")
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
