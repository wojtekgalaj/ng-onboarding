module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        files: {
          "spec/build/specs.js": ["spec/*.coffee"],
          "dist/ng-onboarding.js": ["src/*.coffee"]
        }
      }
    },
    uglify: {
      my_target: {
        files: {
          "dist/ng-onboarding.min.js": "dist/ng-onboarding.js"
        }
      }
    },
    less: {
      compile: {
        files: {
          "dist/ng-onboarding.css": ["src/ng-onboarding.less"]
        }
      }
    },
    watch: {
      scripts: {
        files: ['**/*.coffee', '**/*.less'],
        tasks: ['coffee', 'uglify', 'less', 'copy'],
        options: {
          debounceDelay: 250,
        },
      }
    },
    zip: {
      'package': {
        cwd: 'dist/',
        src: ['dist/*.js', 'dist/*.css'],
        dest: 'dist/ng-onboarding.zip'
      }
    },
    copy: {
      main: {
        files: [
          {
            expand: true,
            src: 'dist/ng-onboarding.*',
            dest: 'Add a route to your project',
            filter: 'isFile'
          }
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-zip');

  grunt.registerTask('default', ['coffee', 'uglify', 'less', 'watch']);
  grunt.registerTask('copy-to-project', ['coffee', 'uglify', 'less', 'copy', 'watch']);
  grunt.registerTask('package', ['coffee', 'uglify', 'less', 'zip']);
};
