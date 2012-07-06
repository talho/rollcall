json.options [{
  :absenteeism => @options[:default_options][:absenteeism],
  :age => @options[:default_options][:age],
  :data_functions => @options[:default_options][:data_functions],
  :data_functions_adv => @options[:default_options][:data_functions_adv],
  :gender => @options[:default_options][:gender],
  :symptoms => @options[:default_options][:symptoms],  
  :zipcode => @options[:zipcodes].map{|z| {id: z, value: z}},
  :school_type => @options[:school_types].map{|st| {id: st, value: st}},
  :grade => @options[:grades].map.with_index{|g, i| {id: i+1, value: g} },
  :school_districts => @options[:school_districts],
  :schools => @options[:schools]
}]
