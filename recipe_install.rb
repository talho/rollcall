# Create sym links for report recipes
%W(recipe recipe_internal).each do |folder|
  rel_path = File.join(Rails.root, "vendor","plugins","rollcall","lib", folder)
  target = File.join(Rails.root,"app","models",folder)
  Dir["#{rel_path}/*.rb"].each do |d|
    File.symlink(d, "#{target}/#{File.basename(d)}") unless File.symlink?("#{target}/#{File.basename(d)}")
  end
end
