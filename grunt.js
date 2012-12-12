module.exports = function(grunt) {
    grunt.loadNpmTasks('grunt-coffee');

    grunt.initConfig({
        coffee: {
            app: {
                src: ['app/coffee/*.coffee', 'app/coffee/**/*.coffee'],
                dest: 'app/js/',
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
                dest: 'spec/helpers/',
                options: {
                    bare: false
                }
            }
        },
        lint: {
            files: ['app/js/*.js','app/js/**/*.js','spec/js/**/*.js']
        },
        watch: {
            files: ['<config:jasmine.specs>','src/**/*js'],
            tasks: 'jasmine'
        },
        concat: {
          app: {
            src: [
                'lib/js/underscore-1.4.3.js',
                'app/js/app.js',
                'app/js/helpers/dom.js',
                'lib/js/domReady.js',
                'app/js/preloader.js',
                'app/js/events.js'
            ],
            dest: 'app/js/app-package.js'
          }
        },
        jasmine : {
            src : [
                'lib/js/require-2.1.2.js',
                'lib/js/jquery-1.8.3.js', // affix needs jquery (for jasmine fixtures)
                'lib/js/underscore-1.4.3.js', // for custom matchers
                'app/js/app-package.js'
            ],
            specs : 'spec/js/**/*.js',
            helpers : 'spec/helpers/*.js',
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

    grunt.loadNpmTasks('grunt-jasmine-runner');


    grunt.registerTask('spec', 'coffee concat jasmine');
    grunt.registerTask('spec-server', 'coffee concat jasmine-server');
};