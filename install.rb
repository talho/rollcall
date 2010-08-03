# Install hook code here
parent_lib_dir = File.join(Rails.root, "lib")
[ "workers" ].each { |lib_subdir|
  rel_path = File.join("..","..","vendor","plugins","rollcall","lib",lib_subdir)
  File.symlink(rel_path, File.join(parent_lib_dir, lib_subdir, "rollcall"))
}

# Create links in Rails.root/public so that the register_javascript_expansion()
# and register_stylesheet_expansion() methods can see the plugin's files.
parent_public_dir = File.join(Rails.root, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
  rel_path = File.join("..","..","vendor","plugins","rollcall","public",public_subdir)
  File.symlink(rel_path, File.join(parent_public_dir, public_subdir, "rollcall"))
}
