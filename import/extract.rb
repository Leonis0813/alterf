Dir[File.join(Settings.application_root, 'import/extract/*.rb')].each {|file| require file }

def extract(resource_type, html)
  send("parse_#{resource_type}", html.gsub("\n", '').gsub('&nbsp;', ' '))
end
