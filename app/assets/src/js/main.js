requirejs.config({
  baseUrl: 'app/assets/src/js',
  paths: {
    'text':       '../../vendor/js/require/text',
    'jquery':     '../../vendor/js/jquery-2.0.3',
    'jquery-ui':     '../../vendor/js/jquery-ui-1.10.3.custom',
    'requireLib': '../../vendor/js/require',
    'backbone':   '../../vendor/js/backbone',
    'lodash':     '../../vendor/js/lodash.custom',
    'Handlebars':             '../../vendor/js/handlebars-1.0.0',
    'hbs':                    '../../vendor/js/hbs/hbs',
    'hbs/i18nprecompile':     '../../vendor/js/hbs/i18nprecompile',
    'jqModal':     '../../vendor/js/jqModal',
    'inflection':     '../../vendor/js/inflection',
    'moment':     '../../vendor/js/moment-2.4.0',
    'bootstrap':     '../../vendor/js/bootstrap-3.0.0'
  },

  shim: {
    'jquery': { exports: '$' },
    'jquery-ui': { deps: [ 'jquery' ] },
    'backbone': {
      deps: [ 'lodash' ],
      exports: 'Backbone'
    },
    'lodash': { exports: '_' },
    'inflection': {},
    'bootstrap': [ 'jquery' ],
    'moment': { exports: 'moment' },
    'jqModal': [ 'jquery' ]
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
  'bootstrap',
  'jqModal',
  'algol',
  'algol_ui',
  'ext/jquery',
  'lodash',
  'backbone'
], function() {});