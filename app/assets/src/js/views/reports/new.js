define([ 'ext/jquery', 'backbone' ], function($, Backbone) {
  return Backbone.View.extend({
    render: function() {
      $('label input[type="radio"]').each(function() {
        var $radio = $(this);
        var $bootstrap_container = $('<div class="radio" />')
        var $label = $radio.parents('label:first');
        $label.after($bootstrap_container);
        $label.appendTo($bootstrap_container);
      });

      $('label input[type="checkbox"]').each(function() {
        var $radio = $(this);
        var $label = $radio.parents('label:first');
        // Tag filter checkboxes should be inlined
        var klass = $label.parents('#tag_filters').length ? 'checkbox-inline' : 'checkbox';
        var $bootstrap_container = $('<div class="' + klass + '" />')

        $label.after($bootstrap_container);
        $label.appendTo($bootstrap_container);
      });

      $( "#from" ).datepicker({
        defaultDate: "+1w",
        inline: false,
        changeMonth: true,
        numberOfMonths: 1,
        onClose: function( selectedDate ) {
          $( "#to" ).datepicker( "option", "minDate", selectedDate );
        }
      });
      $( "#to" ).datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        numberOfMonths: 1,
        onClose: function( selectedDate ) {
          $( "#from" ).datepicker( "option", "maxDate", selectedDate );
        }
      });

      $('#date_filters input[name*="range"]').on('change', function() {
        $('#report_date_selector').toggle($('#date_filters :checked').val() === 'custom');
      });

      var form_url = $("form").attr("action");

      $('input[name="type"]').on('change', function() {
        var form = $(this).parents("form:first")
        if ($(this).attr("value") == 'PDF') {
          form.attr("action", form_url + '.pdf')
        } else {
          form.attr("action", form_url)
        }
      });

      $('input[type="radio"]:checked, input[type="checkbox"]:checked').change();
    }
  });
});