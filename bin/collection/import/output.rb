require 'fileutils'
require_relative '../config/settings'
require_relative '../lib/logger'

def output(resource, string, file_name)
  FileUtils.mkdir_p(Settings.backup_dir[resource])
  file_path = File.join(Settings.backup_dir[resource], file_name)
  File.open(file_path, 'w') {|out| out.write(string) }
  Logger.info(
    :action => 'output',
    :resource => resource,
    :file_name => file_name,
    :length => string.length,
    :lines => string.lines.size
  )
  file_path
end
