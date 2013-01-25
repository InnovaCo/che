assets = require '../helpers/assets'
path = require 'path'
fs = require 'fs'

getFilesRecursivly = (dir, prefix) ->
  contents = fs.readdirSync(dir)
  files = []
  for file in contents
    if not file.match ///\.(coffee|js)///
      files = files.concat(getFilesRecursivly dir + "/#{file}", prefix + "#{file}/")
    else
      file = file.replace /\.coffee$/, ".js"
      files.push prefix + file

  return files


exports.jasmine_helper = (req, res) ->
  res.header 'Content-Type', 'application/x-javascript'
  filePath = path.resolve(__dirname, "../../node_modules/grunt-jasmine-runner/tasks/jasmine/jasmine-helper.js")
  res.send fs.readFileSync filePath

exports.jasmine = (req, res) ->
  res.header 'Content-Type', 'application/x-javascript'
  filePath = path.resolve(__dirname, "../../node_modules/grunt-jasmine-runner/jasmine/lib/jasmine-core/jasmine.js")
  res.send fs.readFileSync filePath

exports.jasmine_html = (req, res) ->
  res.header 'Content-Type', 'application/x-javascript'
  filePath = path.resolve(__dirname, "../../node_modules/grunt-jasmine-runner/jasmine/lib/jasmine-core/jasmine-html.js")
  res.send fs.readFileSync filePath


exports.jasmine_css = (req, res) ->
  res.header 'Content-Type', 'text/css'
  filePath = path.resolve(__dirname, "../../node_modules/grunt-jasmine-runner/jasmine/lib/jasmine-core/jasmine.css")
  res.send fs.readFileSync filePath

appCoreDepency = [
  "public/js/lib/require-2.1.2.js",
  "public/js/lib/underscore-1.4.3.js",
  "public/js/lib/jquery-1.8.3.js",
  'public/js/app-require-config.js'
]

jasmineCss = [
  'jasmine.css'
]

jasmineCore = [
  'jasmine.js',
  'jasmine-html.js'
]

exports.init = (req, res) ->

  filesToInclude = appCoreDepency
  filesToInclude = filesToInclude.concat jasmineCore

  filesToInclude = filesToInclude.concat getFilesRecursivly(path.resolve(__dirname, "../../spec/"), "spec/")

  filesToInclude.push 'jasmine-helper.js'

  res.render "specs"
    css: jasmineCss
    js: filesToInclude


exports.assets = (req, res) ->
  res.header 'Content-Type', 'application/x-javascript'
  assets.coffee path.resolve(__dirname, "../../spec/" + req.params[0]), (file) ->
    if file 
      res.send file
    else
      res.send 404