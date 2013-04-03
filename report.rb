require './storage'

def ranks_for_app_id(app_id)
  s = Nutte::Storage.new
  app_meta = s.app_metadata_by_app_id(app_id)
  ranks = s.ranks_by_app_id(app_id)
  puts "#{app_meta['name']}:"
  puts "ranks: "
  ranks.each {|rank|
    puts rank.to_s
  }
end

def ranks_for_app_name(app_name)
  s = Nutte::Storage.new
  apps = s.find_apps_by_name(app_name)
  apps.each {|app|
    ranks_for_app_id(app['id'])
  }
  
end
