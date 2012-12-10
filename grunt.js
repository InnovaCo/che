module.exports = function(grunt) {
    grunt.loadNpmTasks('grunt-coffee');

    grunt.initConfig({
        coffee: {
            app: {
                src: ['app/coffee/*.coffee'],
                dest: 'app/javascripts/',
                options: {
                    bare: false
                }
            },
            tests: {
                src: ['spec/coffee/**/*coffee'],
                dest: 'spec/javascripts/',
                options: {
                    bare: false
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
        jasmine : {
            src : ['app/javascripts/**/*.js', 'lib/javascripts/**/*.js'],
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


    grunt.registerTask('spec', 'coffee jasmine');
    grunt.registerTask('spec-server', 'coffee jasmine-server');
};