# Install hook code here
parent_lib_dir = File.join(Rails.root.to_s, "lib")
# Require the creation of plugin_workers under PHIN
Dir.ensure_exists(File.join(Rails.root.to_s, "lib/workers/plugin_workers"))
[ "workers" ].each { |lib_subdir|
 rel_path = File.join(Rails.root.to_s+"vendor","plugins","rollcall","lib",lib_subdir)
 target = File.join(parent_lib_dir, lib_subdir, "plugin_#{lib_subdir}")
 Dir["#{rel_path}/*.rb"].each do |d|
   File.symlink(d, "#{target}/#{File.basename(d)}") unless File.symlink?("#{target}/#{File.basename(d)}")
 end
}

## Create sym links for specs
#rel_path = File.join("..", "vendor","plugins","rollcall","spec")
#target = File.join(Rails.root.to_s "spec", "rollcall")
#File.symlink(rel_path, target) unless File.symlink?(target)

# Create links in Rails.root.to_spublic so that the register_javascript_expansion()
# and register_stylesheet_expansion() methods can see the plugin's files.
parent_public_dir = File.join(Rails.root.to_s, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
 rel_path = File.join("..","..","vendor","plugins","rollcall","public",public_subdir)
 target = File.join(parent_public_dir, public_subdir, "rollcall")
 File.symlink(rel_path, target) unless File.symlink?(target)
}
