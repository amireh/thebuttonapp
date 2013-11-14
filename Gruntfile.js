module.exports = function(grunt) {
  'use strict';

  var config;
  var shell = require('shelljs');

  function readPkg() {
    return grunt.file.readJSON('package.json');
  };

  function loadFrom(path, config) {
    var glob = require('glob'),
    object = {};

    glob.sync('*', {cwd: path}).forEach(function(option) {
      var key = option.replace(/\.js$/,'').replace(/^grunt\-/, '');
      config[key] = require(path + option);
    });
  };

  config = {
    pkg: readPkg(),
    env: process.env
  };

  loadFrom('./lib/tasks/grunt/', config);

  grunt.initConfig(config);

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-notify');

  // grunt.registerTask('test', [ 'jsvalidate', /* 'jshint', */ ]);
  grunt.registerTask('build', [
    'requirejs',
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