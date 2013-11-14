module.exports = {
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
};