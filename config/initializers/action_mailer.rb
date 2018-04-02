ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_url_options = {
  :host => '192.168.33.10',
  :port => 3000,
  :script_name => '/alterf',
}
ActionMailer::Base.smtp_settings = {
  address: 'smtp.gmail.com',
  domain: 'gmail.com',
  port: 587,
  user_name: 'GMAIL_USER_NAME',
  password: 'GMAIL_PASSWORD',
  authentication: 'plain',
  enable_starttls_auto: true,
}
