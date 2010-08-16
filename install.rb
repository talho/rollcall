# Install hook code here
parent_lib_dir = File.join(Rails.root, "lib")
[ "workers" ].each { |lib_subdir|
  rel_path = File.join("..","..","vendor","plugins","rollcall","lib",lib_subdir)
  target = File.join(parent_lib_dir, lib_subdir, "rollcall")
  File.symlink(rel_path, target) unless File.symlink?(target)
}

rel_path = File.join("..","..","..","..","spec","spec_helper.rb")
target = "#{Rails.root}/vendor/plugins/rollcall/spec/spec_helper.rb"
File.symlink(rel_path, target) unless File.symlink?(target)

# Create links in Rails.root/public so that the register_javascript_expansion()
# and register_stylesheet_expansion() methods can see the plugin's files.
parent_public_dir = File.join(Rails.root, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
  rel_path = File.join("..","..","vendor","plugins","rollcall","public",public_subdir)
  target = File.join(parent_public_dir, public_subdir, "rollcall")
  File.symlink(rel_path, target) unless File.symlink?(target)
}
