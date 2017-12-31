require 'fileutils'

SRC_DIR = '/mnt/sakura'
DST_DIR = '/mnt/backup/alterf'

%w[ race_list races horses ].each do |directory|
  src_dir = File.join(SRC_DIR, directory)
  dst_dir = File.join(DST_DIR, directory)

  FileUtils.mkdir_p(src_dir)
  FileUtils.mkdir_p(dst_dir)

  src_files = Dir[File.join(src_dir, '*')].map {|file_path| File.basename(file_path) }
  dst_files = Dir[File.join(dst_dir, '*')].map {|file_path| File.basename(file_path) }

  (src_files - dst_files).each {|file_name| FileUtils.cp(File.join(src_dir, file_name), dst_dir) }
end
