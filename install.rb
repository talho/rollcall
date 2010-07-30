# Install hook code here
FileUtils.cp_r(File.join(File.dirname(__FILE__),'lib','workers/.'),File.join(Rails.root,'lib','workers'))

parent_public_dir = File.join(Rails.root, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
  rel_path = File.join("..","..","vendor","plugins","rollcall","public",public_subdir)
  File.symlink(rel_path, File.join(parent_public_dir, public_subdir, "rollcall"))
}
