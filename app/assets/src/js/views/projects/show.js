define([
  'backbone',
  'views/projects/toolbar/move_tasks'
], function(Backbone, MoveTasksView) {
  return Backbone.View.extend({
    events: {
      'click #checkAll': 'selectAllTasks'
    },

    render: function() {
      this.$el = $('#content');
      this.delegateEvents();

      this.moveTasksModal = new MoveTasksView();
      this.moveTasksModal.render();
    },

    selectAllTasks: function() {
      var $checkbox = $('#checkAll');

      $('[name*=task][type="checkbox"]').prop('checked', $checkbox.is(':checked'));
    }
  });
});