define([
  'jquery',
  'bootstrap',
  'util/confirmation_dialog'
], function($) {
  $.consume = function(e) {
    e.preventDefault();

    if (e.stopPropagation) { e.stopPropagation(); }
    if (e.stopImmediatePropagation) { e.stopImmediatePropagation(); }

    return false;
  };

  $.ajaxJSON = function(options) {
    return $.ajax(_.extend(options, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    }));
  };

  var $modalWrapper = $([
    '<div class="modal fade">',
      '<div class="modal-dialog">',
        '<div class="modal-content">',
          '<div class="modal-header">',
            '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>',
          '</div>',
          '<div class="modal-body"></div>',
          '<div class="modal-footer">',
            '<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>',
          '</div>',
        '</div>',
      '</div>',
    '</div>'
  ].join(''));

  $.fn.asModal = function() {
    var $el = $modalWrapper.clone();
    var $this = $(this).clone();
    var $header, $footer;

    $header = $this.find('.modal-title').detach();
    $footer = $this.find('.modal-actions').detach();

    $this.find('.modal-content').removeClass('modal-content');

    $el.find('.modal-header').append($header);
    $el.find('.modal-body').append($this.show());
    $el.find('.modal-footer').append($footer.children());

    $footer.remove();

    return $el;
  };

  /**
   * @method serializeObject
   *
   * Serialize an HTML form element into a JSON construct, with proper type
   * conversions (ie, "true" to true.)
   */
  $.fn.serializeObject = function() {
    var self = this,
        json = {},
        push_counters = {},
        patterns = {
          'validate': /^[a-zA-Z][a-zA-Z0-9_]*(?:\[(?:\d*|[a-zA-Z0-9_]+)\])*$/,
          'key':      /[a-zA-Z0-9_]+|(?=\[\])/g,
          'push':     /^$/,
          'fixed':    /^\d+$/,
          'named':    /^[a-zA-Z0-9_]+$/
        };

    this.build = function(base, key, value){
        base[key] = value;
        return base;
    };

    this.push_counter = function(key){
        if(push_counters[key] === undefined){
            push_counters[key] = 0;
        }
        return push_counters[key]++;
    };

    $.each($(this).serializeArray(), function() {
      // skip invalid keys
      if (!patterns.validate.test(this.name)) {
        return;
      }

      var k,
          keys = this.name.match(patterns.key),
          merge = this.value,
          reverse_key = this.name;

      while ((k = keys.pop()) !== void 0) {
        // adjust reverse_key
        reverse_key = reverse_key.replace(new RegExp('\\[' + k + '\\]$'), '');

        // push
        if ( k.match(patterns.push) ) {
          merge = self.build([], self.push_counter(reverse_key), merge);
        }
        // fixed
        else if ( k.match(patterns.fixed) ){
          merge = self.build([], k, merge);
        }
        // named
        else if ( k.match(patterns.named) ){
          merge = self.build({}, k, merge);
        }
      }

      json = $.extend(true, json, merge);
    });

    return json;
  };


  $.fn.extend({
    formParams: function (params) {

      var convert;

      // Quick way to determine if something is a boolean
      if ( !! params === params) {
        convert = params;
        params = null;
      }

      if (params) {
        return this.setParams(params);
      } else {
        return this.getParams(convert);
      }
    },
    setParams: function (params, options) {
      options = options || {};

      // Find all the inputs
      this.find("[name]").each(function () {
        var $this = $(this);
        var name = $this.attr('name');
        var myval;

        if (options.deindexize) {
          name = name.replace(/\[\]/, '');
        }

        var value = params[name];

        // Don't do all this work if there's no value
        if (value !== undefined) {

          // Nested these if statements for performance
          if ($this.is(":radio")) {
            if ($this.val() == value) {
              $this.prop("checked", true);
            }
          } else if ($this.is(":checkbox")) {
            myval = $this.val();

            // Convert single value to an array to reduce complexity
            value = $.isArray(value) ? value : [value];

            if (options.stringify) {
              myval = String(myval);

              for (var i = 0; i < value.length; ++i) {
                value[i] = String(value[i]);
              }
            }
            else if (options.convert) {
              if (!!Number(myval)) {
                myval = Number(myval);
              }
              else if (String(myval) === 'true') {
                myval = true;
              }
              else if (String(myval) === 'false') {
                myval = false;
              }
            }

            if (value.indexOf(myval) > -1) {
              $this.prop("checked", true);
            }

            if (value.length == 1 && String(value[0]) === 'true') {
              $this.prop("checked", true);
            }

          } else {
            $this.val(value);
          }
        }
      });

      return $(this);
    },
    getParams: function (convert) {
      var data = {},
        // This is used to keep track of the checkbox names that we've
        // already seen, so we know that we should return an array if
        // we see it multiple times. Fixes last checkbox checked bug.
        seen = {},
        current;

      this.find("[name]:not(:disabled)").each(function () {
        var $this = $(this),
          type = $this.attr("type"),
          name = $this.attr("name"),
          value = $this.val(),
          parts;

        // Don't accumulate submit buttons and nameless elements
        if (type == "submit" || !name) {
          return;
        }

        // Figure out name parts
        parts = name.match(keyBreaker);
        if (!parts.length) {
          parts = [name];
        }

        // Convert the value
        if (convert) {
          value = convertValue(value, $this);

          if (value === undefined)
            return;
        }

        // Assign data recursively
        nestData($this, type, data, parts, value, seen);

      });

      return data;
    }
  });

  return $;
});