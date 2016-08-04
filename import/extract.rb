def extract(resource_type, html)
  require_relative "extract/#{resource_type}"
  parse(html)
end
