define([ 'jquery', 'hbs!templates/confirmation_dialog' ], function($, Template) {
  var $dialog = $(Template({})).appendTo($('body'));

  /**
   * Attempts to locate a method by its fully-qualified name, ie
   * `dynamism.foo.bar`.
   */
  function method_from_fqn(fqn) {
    var parts = fqn.split('.');
    if (parts.length == 0 && !window[fqn])
      return null;

    var method = window[parts[0]];
    for (var i = 1; i < parts.length; ++i) {
      if (!method)
        return null

      method = method[parts[i]];
    }

    return method;
  } // dynamism::method_from_fqn()

  $(function() {
    var will_be_moving  = false,
        old_root        = null,
        was_hidden      = false;

    algol.confirm = function(msg, heading, callback) {
      var accept_dialogue = function() {
        if (will_be_moving) {
          old_root.append( $dialog.find('p.jqmConfirmMsg').children().detach() );
          // $("#confirm p.jqmConfirmMsg").html('');
          if (was_hidden) {
            old_root.children(":last").hide();
          }
        }

        if($(this).attr("id") == 'confirm_accepted') {
          if (typeof callback == "string") {
            window.location.href = callback;
          } else {
            // try {
              callback();
            // } catch (script_error) {
            //   ui.report_error(script_error);
            // }
          }
        }

        will_be_moving  = false;
        old_root        = null;
        was_hidden      = false;

        $dialog.jqmHide();

        return false;
      }

      $dialog
        .jqmShow()
        .find('h4')
          .html(heading || "Confirmation")
        .end()
        .find('p.jqmConfirmMsg')
          .html(msg)
        .end()
        .find('#confirm_accepted, #confirm_rejected')
          .off('click')
          .click(accept_dialogue);

      $dialog.find('input[type=text]:first').focus();
    }

    $dialog.jqm({
      overlay: 88,
      modal: true,
      trigger: false
    });

    $(document.body).on('click', '.confirm, a.bad, a[data-confirm]', function(e) {
      var a = $(e.currentTarget);

      try {
        var msg = a.attr("data-confirm");

        if (!msg) {
          var sibling = a.next("[data-confirm]");

          if (!sibling.length) {
            sibling = $( a.attr('data-confirm-target') || '' );
          }

          console.log(sibling);

          if (sibling.length > 0) {
            if (sibling.attr("data-confirm") == 'move') {
              will_be_moving = true;
              old_root = sibling.parent();
              was_hidden = sibling.is(":hidden");

              if (was_hidden)
                sibling.show();

              msg = sibling.detach();
            } else {
              msg = sibling.html();
            }
          }
        }

        var heading = a.attr('data-confirm-heading') || 'Confirmation';
        var accept_label = a.attr('data-confirm-accept') || 'Yes';

        if (!msg || msg.length == "") {
          var confirmable_parent = a.parents('[data-confirmable]:first');
          obj = confirmable_parent;

          if (confirmable_parent.length > 0) {
            var id = confirmable_parent.attr('data-confirmable');
            var infix = confirmable_parent.attr('data-confirmable-infix') ||
              a.html().toLowerCase();

            id += '_' + infix + '_';
            id += 'confirmation';

            confirmable = $('#' + id);

            heading = confirmable.find('> h1:first').html();
            msg = confirmable.find('> p:first').html();

            if (confirmable.find('span[data-label]').length > 0) {
              accept_label = confirmable.find('span[data-label]:first').html()
            }
          }
        }

        $dialog.find('#confirm_accepted').attr('value', accept_label);

        if (!a.attr('data-confirm-cb')) {
          algol.confirm(msg, heading, a.attr('href'));
        } else {
          algol.confirm(msg, heading, function() {
            var method = method_from_fqn(a.attr('data-confirm-cb'));
            if (method) {
              return method(a);
            } else {
              console.log('ERROR: invalid confirmation callback: ' + a.attr('data-confirm-cb'));
            }
          });
        }
      } catch (e) {
        console.log('ERROR: something bad happened while showing the cnfm dialog: ')
        console.log(e);

        $dialog.jqmHide();
        ui.report_error(e)
      }

      return false;
    });

  });
});