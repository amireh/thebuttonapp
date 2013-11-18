define([ 'ext/jquery' ], function($) {
  var confirmationMessage = [
    'This is a destructive action and can not be undone.',
    '',
    'Are you sure you want to continue?'
  ].join('\n');

  $(document.body).on('click', '.confirmable, .btn-danger[href*="destroy"]', function(e) {
    if (!confirm(confirmationMessage)) {
      return $.consume(e);
    }

    return true;
  });
});