module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-docco');
  grunt.loadNpmTasks('grunt-requirejs');
  grunt.loadNpmTasks('grunt-clean');
  grunt.loadNpmTasks('grunt-jasmine-runner');
  grunt.loadNpmTasks('grunt-contrib-stylus');

  grunt.initConfig({

    /* Coffee-script */
    coffee: {
      app: {
        src: ['app/client/*.coffee', 'app/client/**/*.coffee', 'app/client/**/*.js'],
        dest: 'public/js/',
        options: {
          bare: false,
          preserve_dirs: true,
          base_path: 'app/client'
        }
      },
      tests: {
        src: ['spec/coffee/**/*coffee'],
        dest: 'spec/js/',
        options: {
          bare: false,
          preserve_dirs: true,
          base_path: 'spec/coffee'
        }
      },
      jasmine_helpers: {
        src: ['spec/helpers/**/*coffee'],
        dest: 'spec/helpers/js',
        options: {
          bare: false,
          preserve_dirs: true,
          base_path: 'spec/helpers/coffee'
        }
      }
    },

    /* Stylus */
    stylus: {
      compile: {
        options: {
          compress: true
        },
        files: {
          'public/b/style.css': ['public/b/style.styl']
        }
      }

    },

    /* DOCCO */
    docco: {
      app: {
        src: [
          'src/*.coffee'
        ]
      }
    },

    /* Require.js */
    requirejs: {
      compile: {
        options: {
          baseUrl: "public/js/",
          name: "app",
          include: ["loader", "events"],
          out: "public/js/app-require-optimized.js",
          optimize: "none"
        }
      }
    },


    /* Jasmine tests */
    jasmine : {
      src : [
        'public/js/lib/jquery-1.8.3.js', // affix needs jquery (for jasmine fixtures)
        'public/js/app-package.js'
      ],
      specs : 'spec/js/**/*_spec.js',
      helpers : 'spec/helpers/**/*.js',
      timeout : 10000,
      junit : {
        output : '.junit-output/'
      }
    },


    /* JSLint */
    lint: {
      files: ['public/js/*.js','app/js/**/*.js','spec/js/**/*.js']
    },

    /* JS Hint */
    jshint: {
      options: {
      curly: true,
      eqeqeq: true,
      immed: true,
      latedef: true,
      newcap: true,
      noarg: true,
      sub: true,
      undef: true,
      boss: true,
      eqnull: true,
      node: true,
      es5: true
      },
      globals: {
      jasmine : false,
      describe : false,
      beforeEach : false,
      expect : false,
      it : false,
      spyOn : false
      }
    },

    /* Concatenation & clean */
    concat: {
      app: {
      src: [
        'public/js/lib/require-2.1.2.js',
        'public/js/lib/underscore-1.4.3.js',
        'public/js/app-require-config.js',
        'public/js/app-require-optimized.js'
      ],
      dest: 'public/js/app-package.js'
      }
    },
    clean: {
      file: 'public/js/app-require-optimized.js'
    },


    /* Watch tasks */
    watch: {
      tests: {
        files: ['<config:jasmine.specs>','src/**/*js'],
        tasks: 'jasmine'
      },
      stylus: {
        files: ['public/b/b**/b**.styl', 'public/b/*.styl'],
        tasks: 'stylus'
      }
    },


  });

  
  grunt.registerTask('require', 'coffee requirejs stylus concat clean');
  grunt.registerTask('spec', 'require jasmine');
  grunt.registerTask('spec-server', 'require jasmine-server');
  grunt.registerTask('default', 'spec-server docco');
};