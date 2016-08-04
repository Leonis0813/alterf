require_relative '../settings/settings'

def output(resource_type, string, id)
  File.open(Settings.backup_dir[resource_type].sub(':id', id), 'w') do |out|
    out.write(string)
  end
end
