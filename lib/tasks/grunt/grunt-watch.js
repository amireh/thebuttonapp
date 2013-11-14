module.exports = {
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
};