requirejs.config({
  baseUrl: '/app/assets/src/js',
  paths: {
    /**
     * require.js
     */
    'requireLib': '../../vendor/js/require',
    'text':       '../../vendor/js/require/text',

    /**
     * jQuery and friends
     */
    'jquery': '../../vendor/js/jquery-2.0.3',
    'jquery-ui': '../../vendor/js/jquery-ui-1.10.3.custom',
    'jqModal': '../../vendor/js/jqModal',
    'bootstrap': '../../vendor/js/bootstrap-3.0.0',

    /**
     * Backbone and friends
     */
    'backbone':   '../../vendor/js/backbone',
    'lodash':     '../../vendor/js/lodash.custom',

    /**
     * Handlebars
     */
    'Handlebars': '../../vendor/js/handlebars-1.0.0',
    'hbs': '../../vendor/js/hbs/hbs',
    'hbs/i18nprecompile': '../../vendor/js/hbs/i18nprecompile',

    /**
     * Utility
     */
    'inflection': '../../vendor/js/inflection',
    'moment': '../../vendor/js/moment-2.4.0'
  },

  shim: {
    /**
     * jQuery and friends
     */
    'jquery': { exports: '$' },
    'jquery-ui': [ 'jquery' ],
    'bootstrap': [ 'jquery' ],
    'jqModal': [ 'jquery' ],

    /**
     * Backbone and friends
     */
    'lodash': { exports: '_' },
    'backbone': {
      deps: [ 'lodash' ],
      exports: 'Backbone'
    },

    'Handlebars': { exports: 'Handlebars' },

    /**
     * Utility
     */
    'inflection': {},
    'moment': { exports: 'moment' },
  },

  hbs: {
    templateExtension:  "",
    disableI18n:        true,
    disableHelpers:     true
  }
});

require([
  'text',
  'jquery',
  'jquery-ui',
  'jqModal',
  'bootstrap',
  'algol',
  'algol_ui',
  'ext/jquery',
  'lodash',
  'backbone',
  'Handlebars',
  'inflection',
  'bundles/navigation'
], function() {
  console.debug('thebuttonapp dependencies loaded.')
});