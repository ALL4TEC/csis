const TerserPlugin = require("terser-webpack-plugin");

process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const environment = require('./environment');
const config = environment.toWebpackConfig();
config.devtool = false;
config.optimization = {
  minimize: true,
  minimizer: [new TerserPlugin()],
};
module.exports = config;
