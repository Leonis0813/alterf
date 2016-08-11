require_relative '../settings/settings'

def output(resource_type, string, file_name)
  file_path = File.join(Settings.backup_dir[resource_type], file_name)
  File.open(file_path, 'w') {|out| out.write(string) }
  file_path
end
