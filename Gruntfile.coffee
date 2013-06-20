module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-livereload"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-groc"
  grunt.loadNpmTasks "grunt-open"
  grunt.loadNpmTasks "grunt-regarde"
  grunt.loadNpmTasks "grunt-concat-sourcemap"
  grunt.loadTasks "tasks"

  grunt.initConfig
    path:
      source:
        client: "app/client"
        spec: "spec/coffee"
        jasmine_helpers: "spec/helpers"
      dest:
        client: "public/js/"
        spec: "spec/js/"
        jasmine_helpers: "spec/helpers/js/"
        dependency_graph: "doc/dependency/"

    # Just Copy files (библиотеки в чистом виде, или что еще)
    copy:
      app:
        files: [
          expand: true
          cwd: "<%= path.source.client %>"
          src: ["**/*.js"]
          dest: "<%= path.dest.client %>"
        ]

    # Coffee-script
    coffee:
      app:
        files: [
          expand: true
          cwd: "<%= path.source.client %>"
          src: ["**/*.coffee"]
          dest: "<%= path.dest.client %>"
          ext: ".js"
        ]
        options:
          bare: false
          sourceMap: true

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
          sourceMap: true

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
          sourceMap: true

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

    open:
      specs:
        path: "http://localhost:<%= connect.browser.options.port %>/_SpecRunner.html"

    # GROC
    groc:
      app:
        src: ["<%= path.source.client %>/**/*.coffee"]

    # Require.js
    requirejs:
      compile:
        options:
          baseUrl: "public/js/"
          name: "app"
          include: ["loader", "events"]
          out: "public/js/app-require-optimized.js"
          optimize: "none"
          generateSourceMaps: true
          preserveLicenseComments: false
          paths:
            # Хитрый ход (официальный), чтобы not include этот файл в сборку
            underscore: "empty:"
          shim:
            underscore:
              exports: "_"

    # Jasmine tests
    jasmine:
      # affix needs jquery (for jasmine fixtures)
      src: ["public/js/app.js"]
      options:
        vendor: ["public/js/lib/require.js", "public/js/lib/underscore-min.js", "public/js/lib/jquery-1.9.1.min.js"]
        specs: "spec/js/**/*_spec.js"
        helpers: "spec/helpers/**/*.js"
        host: "http://localhost:<%= connect.phantom.options.port %>/"
        junit:
          path: "reports/.junit-output/"
        #template: require('grunt-template-jasmine-istanbul')
        #templateOptions:
        #  coverage: 'reports/coverage.json'
        #  report: 'reports/coverage'
        #template: require('grunt-template-jasmine-requirejs'),
        #templateOptions:
        #  requireConfig:
        #    baseUrl: '.grunt/grunt-contrib-jasmine/src/main/js/'
        timeout: 10000

    # CoffeeLint
    coffeelint:
      app:
        files:
          src: ["app/client/*.coffee","app/client/**/*.coffee"]
        options: grunt.file.readJSON('configs/coffeelint.json')
      specs:
        files:
          src: ["spec/coffee/*.coffee","spec/coffee/**/*.coffee"]
        options: grunt.file.readJSON('configs/coffeelint.json')
      jasmine_helpers:
        files:
          src: ["spec/coffee/*.coffee","spec/coffee/**/*.coffee"]
        options: grunt.file.readJSON('configs/coffeelint.json')

    # Concatenation & clean
    concat:
      app:
        src: ["public/js/app-require-config.js", "public/js/app-require-optimized.js"]
        dest: "public/js/app.js"

    concat_sourcemap:
      concat:
        src: []
        dest: "public/js/app-sourcemap.js"
      app:
        src: ["public/js/app-require-config.js", "public/js/app-require-optimized.js"]
        dest: "public/js/app.js"

    uglify:
      app:
        files:
          "public/js/app-min.js": ["public/js/app.js"]
        # options:
          # sourceMap: "public/js/app.js.map"

    clean:
      optimized: ["public/js/app-require-optimized.js","public/js/app-sourcemap.js","public/js/app-sourcemap.js.map"]
      public: ["public/js"]
      specs: ["spec/js", "spec/helpers/js"]

    dependencygraph:
      default:
        src: ["app/client/*.coffee","app/client/**/*.coffee"]
        dest: "<%= path.dest.dependency_graph %>"
      options:
        baseUrl: "app/client/"
        priorityList:
          "app": 2,
          "underscore": 1.5
        groupList:
          "app": 3,
          "underscore": 2

    # Watch tasks
    #watch:
    #  tests:
    #    files: ["<config:jasmine.specs>", "src/**/*js"]
    #    tasks: "jasmine"

  grunt.registerTask "harvest_sourcemap", "**.", () ->
    fs = require "fs"
    config = grunt.config "requirejs"
    sourceMapPath = config.compile.options.out + ".map"

    if fs.existsSync sourceMapPath 
      sourceMapString = fs.readFileSync sourceMapPath, "utf-8"
      sourceMap = JSON.parse sourceMapString
      filesRegex = /\.(js|coffee)['",]{0,}$/
      fixedSources = []

      if sourceMap
        for item in sourceMap.sources
          if /\.(js|coffee)['",]{0,}$/.test item
            fixedSources.push "public/js/#{item}"
        fixedSources.unshift "public/js/app-require-config.js"
        sourceMap.sources = fixedSources
        grunt.config.set "concat_sourcemap.concat.src", sourceMap.sources

        console.log "Sourcemap has been harvested"

  grunt.registerTask "update_sourcemap", "**.", () ->
    fs = require "fs"
    fixedSources = []
    sourcemapConfig = grunt.config "concat_sourcemap.concat"
    concatConfig = grunt.config "concat.app"
    sourceMapPath = concatConfig.dest + ".map"
    sourceMapFileName = (concatConfig.dest.split "/").pop()

    if fs.existsSync sourcemapConfig.dest
      sourceMapString = fs.readFileSync sourcemapConfig.dest + ".map", "utf-8"
      sourceMap = JSON.parse sourceMapString
      sourceMap.file = sourceMapFileName

      for item in sourceMap.sources
        if (item.indexOf ".js") < 0
          fixedSources.push item.replace "app/client/",""

      sourceMap.sources = fixedSources
      sourceMap.sourceRoot = "../../../app/client/"

      fs.writeFileSync sourceMapPath, JSON.stringify sourceMap

      jsFileString = fs.readFileSync concatConfig.dest, "utf-8"
      jsFileString = jsFileString.replace /\/\/@\ssourceMappingURL=.+/g, ""
      jsFileString = "//@ sourceMappingURL=" + sourceMapFileName + ".map" + jsFileString
      fs.writeFileSync concatConfig.dest, jsFileString

      console.log "Sourcemap has been updated"

  grunt.registerTask "lint", ["coffeelint"]
  # grunt.registerTask "require", ["coffee","requirejs","concat","uglify","clean:optimized"]
  grunt.registerTask "require", ["coffee","requirejs","harvest_sourcemap","concat_sourcemap:concat","concat:app","update_sourcemap","uglify","clean:optimized"]
  grunt.registerTask "livetest", ["open","connect:browser"]

  grunt.registerTask "default", ["clean:public","lint","copy","require"]

  grunt.registerTask "spec", ["clean:specs","default","connect:phantom","jasmine"]
  grunt.registerTask "full", ["clean:specs","default","connect:phantom","jasmine","groc","dependencygraph"]