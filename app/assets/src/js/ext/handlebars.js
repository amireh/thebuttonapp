define([ 'Handlebars' ], function(Handlebars) {
  Handlebars.registerHelper('to_minutes', function(amount) {
    return amount / 60;
  });
});