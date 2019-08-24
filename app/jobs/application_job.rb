class ApplicationJob < ActiveJob::Base
  def execute_script(filename, args)
    command = [
      'eval "$(pyenv init -)"',
      'eval "$(pyenv virtualenv-init -)"',
      'pyenv activate alterf',
      "python #{Rails.root.join('sciprts', filename)} #{args.join(' ')}",
    ].join(' && ')
    is_success = system command
    raise StandardError unless is_success
  end
end
