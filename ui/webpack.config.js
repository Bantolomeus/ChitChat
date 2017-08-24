const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const template = require('html-webpack-template');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name]-[hash].js'
  },
  devServer: {
    // We have a single-page application so do not navigate
    historyApiFallback: true,
    // Forward requests to API, downloads and websocket to the running backend
    proxy: {
      '/ws': {
        target: 'ws://echo.websocket.org',
        ws: true
      }
    },
    // Enable HMR for dev server
    hot: true
  },
  plugins: [
    // Extract css
    new ExtractTextPlugin({
      filename: '[name]-[contenthash].css'
    }),
    // Generate an index.html to serve our application
    new HtmlWebpackPlugin({
      // Required settings
      inject: false,
      template: template,
      // Application window title
      title: 'ChitChat',
      // Create a mount point for our elm app
      appMountId: 'main',
      links: [
        // Link favicons
        {
          href: 'images/favicon-300.png',
          rel: 'apple-touch-icon',
        },
        {
          href: 'images/favicon-300.png',
          rel: 'shortcut icon',
        }
      ]
    }),
    // Enable hot module replacement
    new webpack.HotModuleReplacementPlugin(),
  ],
  module: {
    rules: [
      // Load our Elm files
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node-modules/],
        use: [
          { loader: 'elm-hot-loader' },
          {
            loader: 'elm-webpack-loader',
            options: {
              cacheDirectory: true,
              presets: ['env'],
            }
          },
          { loader: 'elm-webpack-loader' }
        ]
      },
      // Load styles, images, and web-fonts
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          use: 'css-loader',
          fallback: 'style-loader'
        })
      },
      {
        test: /\.(png|jpg|gif)$/,
        use: [
          {
            options: {
              name: './images/[name].[ext]',
            },
            loader: 'file-loader',
          }
        ]
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf|svg)$/,
        use: [
          'file-loader'
        ]
      }
    ]
  }
}
