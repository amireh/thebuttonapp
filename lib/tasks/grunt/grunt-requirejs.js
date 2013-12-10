module.exports = {
  compile: {
    options: {
      baseUrl: 'app/assets/src/js',
      mainConfigFile: 'app/assets/src/js/main.js',
      out: 'public/app.js',
      optimize: 'uglify',

      removeCombined:           false,
      inlineText:               true,
      preserveLicenseComments:  false,

      uglify: {
        toplevel:         true,
        ascii_only:       true,
        beautify:         false,
        max_line_length:  1000,
        no_mangle:        true
      },

      pragmasOnSave: {
        excludeHbsParser:   true,
        excludeHbs:         true,
        excludeAfterBuild:  true
      },

      pragmas: {
        production: true
      },

      paths: {
        'requireLib': '../../vendor/js/require'
      },

      name: 'main',
      include: [ 'main', 'requireLib', 'bundles/everything' ]
    }
  }
};