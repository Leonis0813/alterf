module Denebola
  class Base < ActiveRecord::Base
    file_path = Rails.root.join('config', 'denebola', 'database.yml')
    establish_connection(YAML.load_file(file_path)[Rails.env])
    self.abstract_class = true
  end
end
