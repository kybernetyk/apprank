require './storage'

def ranks_for_app_id(app_id)
  s = Nutte::Storage.new
	puts "starting metadata query"
	STDOUT.flush
  app_meta = s.app_metadata_by_app_id(app_id)
	puts "end metadata query"
	puts "start rank query"
	STDOUT.flush
  ranks = s.ranks_by_app_id(app_id)
	puts "end rank query"
	STDOUT.flush
  puts "#{app_meta['name']}:"
  puts "ranks: "
  ranks.each {|rank|
    puts rank.to_s
		STDOUT.flush
  }
end

def ranks_for_app_name(app_name)
  s = Nutte::Storage.new
	puts "start app query"
	STDOUT.flush
  apps = s.find_apps_by_name(app_name)
	puts "end app query"
	STDOUT.flush
  apps.each {|app|
    ranks_for_app_id(app['id'])
  }
  
end
