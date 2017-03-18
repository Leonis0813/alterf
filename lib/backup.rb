require 'fileutils'

SRC_DIR = '/mnt/sakura'
DST_DIR = '/mnt/alterf'

%w[ race_list races horses ].each do |directory|
  src = File.join(SRC_DIR, directory)
  dst = File.join(DST_DIR, directory)
  FileUtils.cp(Dir[src] - Dir[dst], dst)
end
