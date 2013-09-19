module.exports = function(grunt) {
  'use strict';

  var src  = 'www/src';
  var dist = 'www/dist';
  var assets = 'www/assets';

  var jsSources = [
    'app/assets/js/**/*.js'
  ];

  var readPkg = function() {
    return grunt.file.readJSON('package.json');
  };

  grunt.initConfig({
    pkg: readPkg(),

    concat: {
      options: {
        separator: ';',
      },
      dist: {
        // src: jsSources,
        src: [
          // 'app/assets/vendor/js/jquery-2.0.3.js',
          'app/assets/vendor/js/jquery-1.9.1.js',
          'app/assets/vendor/js/jquery-ui-1.10.3.custom.js',
          'app/assets/vendor/js/bootstrap-3.0.0.js',
          'app/assets/vendor/js/jqModal.js',
          'app/assets/src/js/algol.js',
          'app/assets/src/js/algol_ui.js'
        ],
        dest: 'public/app-debug.js',
      },
    },


    /**
     * CSS compilation.
     */
    less: {
      options: {
        strictImports: true
      },
      production: {
        options: {
          paths: [ 'app/assets/src/css' ],
          compress: true
        },
        files: {
          'public/app.css': 'app/assets/src/css/app.less',
          'public/app-pdf.css': 'app/assets/src/css/pdf.less'
        }
      }
    },

    /**
     * Watchers.
     */
    watch: {
      options: {
        nospawn: true
      },
      css: {
        files: 'app/assets/{src,vendor}/css/**/*.{less,css}',
        tasks: [ 'less', 'notify:less', 'notify' ]
      },
      js: {
        files: 'app/assets/{src,vendor}/js/**/*.js',
        tasks: [ 'concat' ]
      }
    },

    uglify: {
      options: {
        mangle: true
      },
      compile: {
        files: {
          'public/app.js': [ 'public/app-debug.js' ]
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-notify');

  // grunt.registerTask('test', [ 'jsvalidate', /* 'jshint', */ ]);
  grunt.registerTask('build', [
    'concat',
    'uglify',
    'less'
  ]);
  grunt.registerTask('default', [ 'build' ]);

  grunt.registerTask('notify', function(target) {
    var message;

    switch( target ) {
      case 'less':
        message = 'LESS finished compiling.';
      break;
    }

    grunt.config.set('notify.options.message', message);
  });

};