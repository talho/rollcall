# Install hook code here
FileUtils.cp_r(File.join(File.dirname(__FILE__),'lib','workers/.'),File.join(Rails.root,'lib','workers'))

# Create links in Rails.root/public so that the register_javascript_expansion()
# and register_stylesheet_expansion() methods can see the plugin's files.
parent_public_dir = File.join(Rails.root, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
  rel_path = File.join("..","..","vendor","plugins","rollcall","public",public_subdir)
  File.symlink(rel_path, File.join(parent_public_dir, public_subdir, "rollcall"))
}
