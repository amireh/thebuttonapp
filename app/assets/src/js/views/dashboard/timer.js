define([
  'lodash',
  'backbone',
  'jquery',
  'moment'
], function(_, Backbone, $, moment) {
  return Backbone.View.extend({
    template: _.template('<span><%= seconds %></span>'),

    render: function(anchor) {
      var now = moment.utc();
      this.anchor = moment.utc(anchor);

      this.$el = $( this.template( { seconds: 0 } ) );

      this.timestamp = moment.utc();
      this.timestamp.set('hour', 0);
      this.timestamp.set('minute', 0);
      this.timestamp.set('second', 0);

      var diff = now.diff( this.anchor, 'seconds');

      this.timestamp.add('seconds', diff);

      console.debug(this.timestamp.format('HH:mm:ss'));
      this.start();
    },

    start: function() {
      this.timer = setInterval(_.bind(this.tick, this), 1000);
      this.$el.show();
      this.tick();
    },

    pause: function() {
      if (this.timer) {
        clearInterval(this.timer);
        this.timer = null;
      }
    },

    tick: function() {
      this.timestamp.add('seconds', 1);
      this.$el.text(this.timestamp.format('HH:mm:ss'));
    },

    serialize: function() {
      return this.timestamp.diff( this.anchor, 'seconds' );
    }
  });
});