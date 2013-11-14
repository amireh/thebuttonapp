define([
  'ext/jquery',
  'backbone',
  'hbs!templates/projects/toolbar/move_tasks'
], function($, Backbone, Template) {
  return Backbone.View.extend({
    events: {
      'click [data-action="moveTasks"]': 'showModal'
    },

    render: function() {
      this.$el = $('#content');
      this.$modal = $(Template({})).asModal();

      this.delegateEvents();
    },

    showModal: function() {
      this.$modal.modal('show');
    }
  });
});