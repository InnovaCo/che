module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-docco');
  grunt.loadNpmTasks('grunt-requirejs');
  grunt.loadNpmTasks('grunt-clean');
  grunt.loadNpmTasks('grunt-jasmine-runner');

  grunt.initConfig({
    coffee: {
      app: {
        src: ['app/coffee/*.coffee', 'app/coffee/**/*.coffee'],
        dest: 'public/js/',
        options: {
          bare: false,
          preserve_dirs: true,
          base_path: 'app/coffee'
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
    docco: {
      app: {
        src: [
          'app/coffee/*.coffee'
        ]
      }
    },
    requirejs: {
      compile: {
        options: {
          baseUrl: "public/js",
          name: "app",
          include: ["loader", "events"],
          out: "public/js/app-require-optimized.js",
          optimize: "none"
        }
      }
    },
    lint: {
      files: ['public/js/*.js','public/js/**/*.js','spec/js/**/*.js']
    },
    watch: {
      files: ['<config:jasmine.specs>','src/**/*js'],
      tasks: 'jasmine'
    },
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
    }
  });

  
  grunt.registerTask('require', 'coffee requirejs concat clean docco');
  grunt.registerTask('spec', 'require jasmine');
  grunt.registerTask('spec-server', 'require jasmine-server');
  grunt.registerTask('default', 'spec-server');
};