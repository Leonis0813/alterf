require 'fileutils'
require_relative '../config/settings'

def output(resource, string, file_name)
  FileUtils.mkdir_p(Settings.backup_dir[resource])
  file_path = File.join(Settings.backup_dir[resource], file_name)
  File.open(file_path, 'w') {|out| out.write(string) }
  file_path
end
