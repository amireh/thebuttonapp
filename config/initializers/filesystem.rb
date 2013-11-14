configure do
  set :views, File.join(settings.root, 'app', 'views')
  set :tmp_folder, File.join(settings.root, 'tmp')
  FileUtils.mkdir_p File.join(settings.tmp_folder, 'reports')
end