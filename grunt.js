module.exports = function(grunt) {
    grunt.loadNpmTasks('grunt-coffee');

    grunt.initConfig({
        coffee: {
            app: {
                src: ['app/coffee/**/*.coffee'],
                dest: 'app/javascripts/',
                options: {
                    bare: false,
                    preserve_dirs: true,
                    base_path: 'app/coffee'
                }
            },
            tests: {
                src: ['spec/coffee/**/*coffee'],
                dest: 'spec/javascripts/',
                options: {
                    bare: false,
                    preserve_dirs: true,
                    base_path: 'spec/coffee'
                }
            }
        },
        lint: {
            files: ['app/javascripts/**/*.js','spec/javascripts/**/*.js']
        },
        watch: {
            files: ['<config:jasmine.specs>','src/**/*js'],
            tasks: 'jasmine'
        },
        concat: {
          app: {
            src: [
                'app/javascripts/che/app.js',
                'app/javascripts/che/helpers/dom.js',
                'app/javascripts/domReady.js',
                'app/javascripts/che/preloader.js'
            ],
            dest: 'app/javascripts/app.js'
          }
        },
        jasmine : {
            src : [
                'lib/javascripts/**/*.js',
                'app/javascripts/app.js'
            ],
            specs : 'spec/javascripts/**/*.js',
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