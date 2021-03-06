define([
  'jquery',
  'backbone'
], function($, Backbone) {
  return Backbone.View.extend({
    events: {
      'click #selectAll': 'selectAll'
    },

    views: [],

    render: function() {
      this.$el = $('#content');
      this.delegateEvents();
    },

    selectAll: function() {
      var $checkbox = $('#checkAll');

      $('[type="checkbox"]').prop('checked', $checkbox.is(':checked'));
    }
  });
});