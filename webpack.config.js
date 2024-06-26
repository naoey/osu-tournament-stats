const path = require("path");
const webpack = require("webpack");
// Extracts CSS into .css file
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const RemoveEmptyScriptsPlugin = require("webpack-remove-empty-scripts");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");

let isDevelopment = process.env.NODE_ENV === "development";

module.exports = {
  mode: isDevelopment ? "development" : "production",
  devtool: isDevelopment ? "eval-source-map" : undefined,
  context: path.resolve("."),
  entry: {
    application: "./app/assets/javascripts/application.js",
  },
  devServer: {
    compress: true,
    port: 3035,
    devMiddleware: {
      writeToDisk: true,
    },
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, "app/assets/builds"),
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.tsx?|.jsx?$/,
        use: "ts-loader",
        exclude: /node_modules/,
      },
      // Add CSS/SASS/SCSS rule with loaders
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [isDevelopment && "style-loader", !isDevelopment && MiniCssExtractPlugin.loader, "css-loader", "sass-loader"].filter(
          Boolean,
        ),
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        use: "file-loader",
      },
    ],
  },
  resolve: {
    // Add additional file types
    extensions: [".js", ".jsx", ".scss", ".css", ".ts", ".tsx"],
  },
  plugins: [
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new CleanWebpackPlugin(),
  ],
  optimization: {
    moduleIds: "deterministic",
    splitChunks: false,
  },
};
