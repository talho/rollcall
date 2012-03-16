## Install hook code here
#parent_lib_dir = File.join(Rails.root, "lib")
## Require the creation of plugin_workers under PHIN
#Dir.ensure_exists(File.join(Rails.root, "lib/workers/plugin_workers"))
#[ "workers" ].each { |lib_subdir|
#  rel_path = File.join(Rails.root,"vendor","plugins","rollcall","lib",lib_subdir)
#  target = File.join(parent_lib_dir, lib_subdir, "plugin_#{lib_subdir}")
#  Dir["#{rel_path}/*.rb"].each do |d|
#    File.symlink(d, "#{target}/#{File.basename(d)}") unless File.symlink?("#{target}/#{File.basename(d)}")
#  end
#}
#
## Create sym links for specs
#rel_path = File.join("..", "vendor","plugins","rollcall","spec")
#target = File.join(Rails.root, "spec", "rollcall")
#File.symlink(rel_path, target) unless File.symlink?(target)
#
## Create sym links for report recipes
#rel_path = File.join(Rails.root, "vendor","plugins","rollcall","lib", "recipe")
#target = File.join(Rails.root,"app","models","recipe")
#Dir["#{rel_path}/*.rb"].each do |d|
#  File.symlink(d, "#{target}/#{File.basename(d)}") unless File.symlink?("#{target}/#{File.basename(d)}")
#end

# Create sym links for report internal recipes
rel_path = File.join(Rails.root, "vendor","plugins","rollcall","lib", "recipe_internal")
target = File.join(Rails.root,"app","models","recipe_internal")
Dir["#{rel_path}/*.rb"].each do |d|
  File.symlink(d, "#{target}/#{File.basename(d)}") unless File.symlink?("#{target}/#{File.basename(d)}")
end

## Create links in Rails.root/public so that the register_javascript_expansion()
## and register_stylesheet_expansion() methods can see the plugin's files.
#parent_public_dir = File.join(Rails.root, "public")
#[ "javascripts", "stylesheets" ].each { |public_subdir|
#  rel_path = File.join("..","..","vendor","plugins","rollcall","public",public_subdir)
#  target = File.join(parent_public_dir, public_subdir, "rollcall")
#  File.symlink(rel_path, target) unless File.symlink?(target)
#}
