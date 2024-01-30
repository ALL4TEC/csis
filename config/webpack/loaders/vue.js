const { dev_server: devServer } = require('@rails/webpacker').config
const path = require('path');

const isProduction = process.env.NODE_ENV === 'production'
const inDevServer = process.argv.find(v => v.includes('webpack-dev-server'))
const extractCSS = !(inDevServer && (devServer && devServer.hmr)) || isProduction

module.exports = {
  test: /\.vue?$/,
  include: path.resolve(__dirname, '../../../app/javascript/components'),
  use: [
    {
      loader: 'vue-loader',
      options: { extractCSS }
    }
  ]
}
