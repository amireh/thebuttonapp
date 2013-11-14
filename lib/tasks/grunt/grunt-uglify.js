module.exports = {
  options: {
    mangle: true
  },
  compile: {
    files: {
      'public/app.js': [ 'public/app-debug.js' ]
    }
  }
};