class ApplicationJob < ActiveJob::Base
  attr_accessor :num_entry

  def execute_script(filename, args)
    ENV['PYENV_ROOT'] = '/usr/local/pyenv'
    ENV['PATH'] = [
      "#{ENV['PYENV_ROOT']}/versions/3.6.6/bin",
      "#{ENV['PYENV_ROOT']}/bin",
      '/usr/bin',
      '/bin',
    ].join(':')

    command = [
      'eval "$(pyenv init -)"',
      'eval "$(pyenv virtualenv-init -)"',
      'pyenv activate alterf',
      "python #{Rails.root.join('scripts', filename)} #{args.join(' ')}",
    ].join(' && ')
    is_success = system command
    raise StandardError unless is_success
  end

  def check_metadata(metadata_file)
    raise StandardError unless File.exist?(metadata_file)

    analysis_id = YAML.load_file(metadata_file)['analysis_id']
    raise StandardError if analysis_id.nil?

    analysis = Analysis.find_by(analysis_id: analysis_id)
    raise StandardError if analysis.nil?

    self.num_entry = analysis.num_entry
  end

  def check_entry_size(entry_size)
    raise StandardError unless num_entry.nil? or num_entry == entry_size
  end
end
