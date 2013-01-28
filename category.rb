module Nutte 
  class Category 
  	attr_accessor :name
  	attr_accessor :id

  	def to_s
  		s = "Category {\n"
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
