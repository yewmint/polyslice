var webpack = require('webpack')

module.exports = {
  entry: './src/polyslice.coffee',
  output: {
    path: __dirname,
    filename: 'polyslice.js'
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      }
    ]
  }
}
