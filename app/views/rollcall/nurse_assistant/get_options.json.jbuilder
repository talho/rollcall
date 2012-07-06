json.options [{
  :race => @options[:default_options][:race],
  :age => @options[:default_options][:age],
  :gender => @options[:default_options][:gender],
  :grade => @options[:default_options][:grade],
  :symptoms => @options[:default_options][:symptoms],
  :zip => @options[:zipcodes],
  :total_enrolled_alpha => @options[:total_enrolled_alpha],
  :app_init => @options[:app_init],
  :school_id => @options[:school_id],
  :school_name => Rollcall::School.find(@options[:school_id]).display_name,
  :schools => @options[:schools]
}]