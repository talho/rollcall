parent_lib_dir = File.join(Rails.root.to_s, "lib")
[ "workers" ].each { |lib_subdir|
  target = File.join(parent_lib_dir, lib_subdir, "rollcall")
  File.unlink(target) if File.symlink?(target)
}

target = File.join(Rails.root.to_s,"vendor","plugins","rollcall","spec", "spec_helper.rb")
File.unlink(target) if File.symlink?(target)

parent_public_dir = File.join(Rails.root.to_s, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
  target = File.join(parent_public_dir, public_subdir, "rollcall")
  File.unlink(target) if File.symlink?(target)
}
