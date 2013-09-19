// status = ui.status;
algol_ui = function() {

  var colors = [];
  var handlers = {
        on_entry: []
      },
      status_timer = null,
      timers = {
        autosave: null,
        sync: null,
        flash: null
      },
      theme = "",
      anime_dur = 250,
      status_shown = false,
      current_status = null,
      status_queue = [],
      animation_dur = 2500,
      pulses = {
        autosave: 30, /* autosave every half minute */
        sync: 5,
        flash: 2.5
      },
      defaults = {
        status: 1
      },
      actions = {},
      removed = {},
      action_hooks = { pages: { on_load: [] } },
      hooks = [
        function() {
          // element tooltips
          $("[title],span[title]").tooltip({ placement: "bottom", delay: { show: 500, hide: 100 } });
        },

        // disable all links attributed with data-disabled
        function() {
          $("a[data-disabled], a.disabled").click(function(e) { e.preventDefault(); return false; });
        },

        function() {
          $("input[data-linked-to],button[data-linked-to]").each(function() {
            var target_id = $(this).attr("data-linked-to");
            var target = $(this).siblings("input[name^=" + target_id + "]:first");
            if (target.length == 0) {
              target = $("#" + target_id);
            }
            var button = $(this);
            target.keyup(function() {
              if ($(this).val().length > 0) {
                button.attr("disabled", null);
              } else {
                button.attr("disabled", "disabled");
              }
            }).keyup();
          });
        }
      ]; // end of hooks


  return {
    hooks: hooks,
    theme: theme,
    action_hooks: action_hooks,

    modal: {
      as_alert: function(resource, callback) {
        if (typeof resource == "string") {

        }
        else if (typeof resource == "object") {
          var resource = $(resource);
          resource.show();
        }
      }
    },

    status: {
      clear: function(cb) {
        if (!$("#status").is(":visible"))
          return (cb || function() {})();

        $("#status").addClass("hidden").removeClass("visible");
        status_shown = false;

        if (cb)
          cb();

        if (status_queue.length > 0) {
          var status = status_queue.pop();
          return ui.status.show(status[0], status[1], status[2]);
        }
      },

      show: function(text, status, seconds_to_show) {
        if (!status)
          status = "notice";
        if (!seconds_to_show)
          seconds_to_show = defaults.status;

        // queue the status if there's one already being displayed
        if (status_shown && current_status != "pending") {
          return status_queue.push([ text, status, seconds_to_show ]);
        }

        // clear the status resetter timer
        if (status_timer)
          clearTimeout(status_timer)

        status_timer = setTimeout("ui.status.clear()", status == "bad" ? animation_dur * 2 : animation_dur);
        $("#status").removeClass("pending good bad").addClass(status + " visible").html(text);
        status_shown = true;
        current_status = status;
      },

      mark_pending: function() {
        // $(".loader").show(250);
        $(".loader").show();
      },
      mark_ready: function() {
        // $(".loader").hide(250);
        $(".loader").hide();
      }
    },

    dialogs: {
    },

    report_error: function(err_msg) {
      ui.status.show("A script error has occured, please try to reproduce the bug and report it.", "bad");
      console.log("Script error:");
      console.log(err_msg);
      try {
        throw new Error('');
      } catch (e) {
        console.log(e.stack);
      }
    },

    process_hooks: function() {
      for (var i = 0; i < ui.hooks.length; ++i) {
        ui.hooks[i]();
      }
    }
  }
}

// globally accessible instance
ui = new algol_ui();

$(function() {
  // foreach(ui.hooks, function(hook) { hook(); });
  for (var i = 0; i < ui.hooks.length; ++i) {
    ui.hooks[i]();
  }
})