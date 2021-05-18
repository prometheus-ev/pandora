const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TerserPlugin = require("terser-webpack-plugin");

module.exports = (env, options) => {
  const mode = options.mode || 'development'

  return {
    mode: mode,
    entry: {
      'styles': './app/assets/styles.scss',
      'ng.app': './app/assets/ng/app.js',
      'ng.styles': './app/assets/ng/styles.scss'
    },
    module: {
      rules: [
        {
          test: /\.js/,
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-react']
          }
        },
        {
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
