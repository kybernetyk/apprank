module Nutte 
  class App
  	attr_reader :name
  	attr_accessor :price
  	attr_accessor :currency
  	attr_accessor :release_date
  	attr_accessor :category_id
  	attr_accessor :category
  	attr_accessor :rank
  	attr_accessor :description
  	attr_accessor :id
  	attr_accessor :artist
  	attr_accessor :artist_id
		attr_accessor :crwal_id
		attr_accessor :crawl_date

  	def to_s
  		s = "App {\n"
  		self.instance_variables.each { |var|
  			s << "\t" << var.to_s	
  			s << " = "
  			if var.to_s == '@description'
  				s << self.instance_variable_get(var).to_s[0..32] << "..."
  			else	
  				s << self.instance_variable_get(var).to_s
  			end
  			s << "\n"
  		}
  		s << "}\n"
  	end
  end
end
