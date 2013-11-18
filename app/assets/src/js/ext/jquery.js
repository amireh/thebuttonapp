define([
  'jquery',
  'bootstrap'
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

  return $;
});