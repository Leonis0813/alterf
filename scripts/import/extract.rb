Dir[File.join(Settings.application_root, 'import/extract/*.rb')].each {|file| require file }

def extract(resource, html)
  send("parse_#{resource}", html)
end
