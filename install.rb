# Install hook code here
FileUtils.cp_r(File.join(File.dirname(__FILE__),'lib','workers/.'),File.join(Rails.root,'lib','workers'))

Dir.glob(File.join(File.dirname(__FILE__),'public','javascripts','*.js')).each do |file|
  link = File.join(Rails.root,'public','javascripts',File.basename(file))
  File.symlink(file,link) unless File.exists?(link)
end

Dir.glob(File.join(File.dirname(__FILE__),'public','stylesheets','*.css')).each do |file|
  link = File.join(Rails.root,'public','stylesheets',File.basename(file))
  File.symlink(file,link) unless File.exists?(link)
end