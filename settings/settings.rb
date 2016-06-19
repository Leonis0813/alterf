require 'yaml'

module Settings
  class << self
    def initialize!
      YAML.load_file('settings/constants.yml').each do |k, v|
        if v.kind_of?(String)
          eval "def #{k}; '#{v}'; end"
        else
          eval "def #{k}; #{v}; end"
        end
      end
    end

    def application_root
      File.expand_path(File.dirname('..'))
    end

    def raw_data_path
      '/opt/alterf/raw_data'
    end
  end
end

Settings.initialize!
