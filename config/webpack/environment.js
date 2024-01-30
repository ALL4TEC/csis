const { environment, config } = require('@rails/webpacker');
const vue =  require('./loaders/vue');
const vueResolver = require('./resolve/vue');
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

const webpack = require("webpack");
const { join } = require('path');

const fileLoader = environment.loaders.get('file');
fileLoader.use[0].options.context = join(config.source_path);

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.Tether': 'tether',
    Popper: ['popper.js', 'default']
  })
);
environment.plugins.append(
  'VueLoaderPlugin',
  new VueLoaderPlugin(),
  new BundleAnalyzerPlugin()
);
environment.loaders.append('vue', vue);
environment.config.merge(vueResolver);
environment.splitChunks();
module.exports = environment;
