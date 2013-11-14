module.exports = {
  options: {
    separator: ';',
  },
  dist: {
    src: [
      'app/assets/vendor/js/jquery-2.0.3.js',
      // 'app/assets/vendor/js/jquery-1.9.1.js',
      'app/assets/vendor/js/jquery-ui-1.10.3.custom.js',
      'app/assets/vendor/js/bootstrap-3.0.0.js',
      'app/assets/vendor/js/jqModal.js',
      'app/assets/vendor/js/lodash.custom.js',
      'app/assets/vendor/js/backbone.js',
      'app/assets/vendor/js/moment-2.4.0.js',
      // 'app/assets/vendor/js/googlecharts.js',
      'app/assets/vendor/js/highcharts-3.0.7/js/highcharts-all.js',
      'app/assets/vendor/js/chartkick.js',
      'app/assets/src/js/algol.js',
      'app/assets/src/js/algol_ui.js',
      'app/assets/src/js/ext/jquery.js'
    ],

    dest: 'public/app-debug.js',
  },
};