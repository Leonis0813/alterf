const config = require('@rails/webpacker/package/config');
if (process.env.RAILS_RELATIVE_URL_ROOT) {
  const path = require('path');
  config.publicPath = path.join(process.env.WEBPACKER_ASSET_HOST || '/', process.env.RAILS_RELATIVE_URL_ROOT, `${config.public_output_path}/`);
  config.publicPathWithoutCDN = path.join(process.env.RAILS_RELATIVE_URL_ROOT, `${config.public_output_path}/`);
}

const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: '@popperjs/core',
    bootstrap: 'bootstrap'
  })
)

module.exports = environment
