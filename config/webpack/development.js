var path = require('path');
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");
const environment = require('./environment');
environment.config.devServer = {
  watchContentBase: true,
  contentBase: [
    path.join(__dirname, '../../app/javascript'),
    path.join(__dirname, '../../app/views'),
    path.join(__dirname, '../../app/helpers'),
    path.join(__dirname, '../../app/reflexes')
  ]
}
const smp = new SpeedMeasurePlugin();
const config = environment.toWebpackConfig();
config.devtool = 'inline-source-map';
module.exports = smp.wrap(config);
