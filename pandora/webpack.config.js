const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TerserPlugin = require("terser-webpack-plugin");

module.exports = (env, options) => {
  const mode = options.mode || 'development'

  return {
    mode: mode,
    entry: {
      'app': './app/assets/app.js',
      'styles': './app/assets/styles.scss',
      'ng.app': './app/assets/ng/app.js',
      'ng.styles': './app/assets/ng/styles.scss'
    },
    module: {
      rules: [
        {
          test: /\.riot$/,
          exclude: /node_modules/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: ['@babel/preset-env']
              },
            },{
              loader: '@riotjs/webpack-loader',
              options: {
                // hot: true, // set it to true if you are using hmr
                // add here all the other @riotjs/compiler options riot.js.org/compiler
                // template: 'pug' for example
            }
          }]
        },{
          test: /\.scss/,
          use: [
            MiniCssExtractPlugin.loader,
            {
              loader: 'css-loader',
              options: {
                url: false,
                import: false
              }
            },
            'sass-loader'
          ]
        }
      ]
    },
    plugins: [new MiniCssExtractPlugin()],
    output: {
      path: path.resolve(__dirname, "public"),
      filename: '[name].js',
      publicPath: '/'
    },
    optimization: {
      minimize: (mode === 'development' ? true : false),
      minimizer: [new TerserPlugin({
        extractComments: false
      })]
    },
    devtool: (mode === 'development' ? 'eval-source-map' : false),
    devServer: {
      contentBase: path.join(__dirname, 'public'),
      port: 4000
    }
  }
}
