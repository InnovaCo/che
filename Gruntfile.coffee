_ = require "underscore"

buildOptions = 
  baseUrl: "<%= path.dest.build %>"
  name: "almond"
  paths:
    "almond": "../<%= path.packages %>/almond/almond"
    "lib/domReady": "../<%= path.source.client %>/lib/domReady"
    "lib/serialize": "../<%= path.source.client %>/lib/serialize"
    "underscore": "empty:"
  include: [
    "app"
    "loader"
    "events"
    "clicks"
    "sections"
    "utils/log"
    "utils/ticker"
    "utils/logWriter"
    "utils/errorHandlers/console"
  ],
  almond: true
  wrap:
    startFile: "<%= path.source.wrappers %>/start.frag"
    endFile: "<%= path.source.wrappers %>/end.frag"
  optimize: "none"
  out: "<%= path.dest.client %>/app.js"

gruntConfig =
  path:
    source:
      client: "app/client"
      wrappers: "app/wrappers"
      spec: "spec/coffee"
      jasmine_helpers: "spec/helpers"
    dest:
      client: "public/js"
      build: "build"
      spec: "spec/js"
      jasmine_helpers: "spec/helpers/js"
      dependency_graph: "doc/dependency"
    packages: "node_modules"

  # Coffee-script
  coffee:
    app:
      files: [
        expand: true
        cwd: "<%= path.source.client %>"
        src: ["**/*.coffee"]
        dest: "<%= path.dest.build %>"
        ext: ".js"
      ]
      options:
        bare: false
        sourceMap: false

    specs:
      files: [
        expand: true
        cwd: "<%= path.source.spec %>"
        src: ["**/*coffee"]
        dest: "<%= path.dest.spec %>"
        ext: ".js"
      ]
      options:
        bare: false
        sourceMap: false

    jasmine_helpers:
      files: [
        expand: true
        cwd: "<%= path.source.jasmine_helpers %>"
        src: ["**/*coffee"]
        dest: "<%= path.dest.jasmine_helpers %>"
        ext: ".js"
      ]
      options:
        bare: false
        sourceMap: false

  connect:
    phantom:
      options:
        port: 8889
        base: "."
    browser:
      options:
        port: 8888
        base: "."
        keepalive: true
    browserWatch:
      options:
        port: 8888
        base: "."
        keepalive: false

  open:
    specs:
      path: "http://localhost:<%= connect.browser.options.port %>/_SpecRunner.html"

  # GROC
  groc:
    app:
      src: ["<%= path.source.client %>/**/*.coffee"]

  # Require.js
  requirejs:
    dev:
      options: buildOptions
    live:
      options: _.extend({}, buildOptions,
        optimize: "uglify2"
        preserveLicenseComments: false
        out: "<%= path.dest.client %>/app-min.js"
      )

  # Jasmine tests
  jasmine:
    test:
      # affix needs jquery (for jasmine fixtures)
      options:
        keepRunner: true
        vendor: [
          "<%= path.packages %>/underscore/underscore-min.js"
          "<%= path.packages %>/requirejs/require.js"
          "<%= path.dest.jasmine_helpers %>/app-config.js"
          "<%= path.packages %>/jquery/jquery.min.js"
          "http://localhost:35729/livereload.js"
        ]
        specs: "<%= path.dest.spec %>/**/*_spec.js"
        helpers: "<%= path.source.jasmine_helpers %>/**/*.js"
        host: "http://localhost:<%= connect.phantom.options.port %>/"
        junit:
          path: "reports/.junit-output/"
      timeout: 10000
    coverage:
      # affix needs jquery (for jasmine fixtures)
      options:
        vendor: [
          "<%= path.packages %>/underscore/underscore-min.js"
          "<%= path.packages %>/requirejs/require.js"
          "<%= path.dest.jasmine_helpers %>/app-config.js"
          "<%= path.packages %>/jquery/jquery.min.js"
        ]
        specs: "<%= path.dest.spec %>/**/*_spec.js"
        helpers: "<%= path.source.jasmine_helpers %>/**/*.js"
        host: "http://localhost:<%= connect.phantom.options.port %>/"
        junit:
          path: "reports/.junit-output/"

        template: require "grunt-template-jasmine-istanbul"
        templateOptions:
          coverage: "reports/coverage.json"
          report: [
              type: "html"
              options:
                dir: "reports/coverage"
            ,
              type: "text-summary"
          ]
          thresholds:
            lines: 75
            statements: 75
            branches: 75
            functions: 90

  # CoffeeLint
  coffeelint:
    app:
      files:
        src: ["<%= path.source.client %>/**/*.coffee"]
      options: require "./configs/coffeelint"
    specs:
      files:
        src: ["<%= path.source.spec %>/**/*.coffee"]
      options: require "./configs/coffeelint"

  dependencygraph:
    default:
      src: ["<%= path.source.client %>/**/*.coffee"]
      dest: "<%= path.dest.dependency_graph %>/"
    options:
      baseUrl: "<%= path.source.client %>"
      priorityList:
        "app": 2,
        "underscore": 1.5
      groupList:
        "app": 3,
        "underscore": 2

  # Watch tasks
  watch:
    options:
      livereload: true
      nospawn: false
    client:
      files: ["<%= path.source.client %>/**/*.coffee"]
      tasks: ["default"]
    tests:
      files: ["<%= path.source.spec %>/**/*.coffee", "<%= path.source.jasmine_helpers %>/**/*.coffee"]
      tasks: ["spec-light", "notify:complete"]

  notify:
    complete:
      options:
        title: "Che"
        message: "build complete"

module.exports = (grunt) ->
  grunt.initConfig gruntConfig

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-groc"
  grunt.loadNpmTasks "grunt-open"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadTasks "tasks"

  grunt.registerTask "lint", ["coffeelint"]
  grunt.registerTask "build", ["coffee:app", "requirejs"]
  grunt.registerTask "build-specs", ["coffee:specs", "coffee:jasmine_helpers"]
  grunt.registerTask "livetest", ["open", "connect:browser"]

  grunt.registerTask "spec", ["lint", "build", "build-specs", "connect:phantom", "jasmine:test"]
  grunt.registerTask "spec-light", ["coffeelint:specs", "build-specs", "jasmine:test:build"]
  grunt.registerTask "full", ["spec", "groc", "dependencygraph", "notify:complete"]
  grunt.registerTask "coverage", ["connect:phantom", "jasmine:coverage"]

  grunt.registerTask "dev", ["build-specs", "open", "connect:browserWatch", "watch"]

  grunt.registerTask "default", ["coffeelint:app", "build", "notify:complete"]
