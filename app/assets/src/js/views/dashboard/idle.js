define([ 'ext/jquery', 'lodash', 'backbone' ], function($, _, Backbone) {
  return Backbone.View.extend({
    events: {
      'change [name="project_id"]': 'onProjectSelection',
      'change [name="task_id"]': 'onTaskSelection',
      'click [data-action="newTask"]': 'newTask'
    },

    user: ENV.USER,
    project: null,
    task: null,

    render: function() {
      this.setElement('#content');
      this.delegateEvents();

      $newTaskForm = $('#newTaskForm');
      $resumeTaskForm = $('#resumeTaskForm');
      $resumeTask = $('#resumeTask');

      $('[name="project_id"]').trigger('change');
    },

    onProjectSelection: function(e) {
      var projectId = $(e.target).val();

      _.each(this.user.clients, function(client) {
        var project = _.find(client.projects, { id: projectId });

        if (project) {
          this.project = project;
        }
      }, this);

      $resumeTask.prop('disabled', true);

      this.updateTaskForm();
      this.updateTaskList();
    },

    onTaskSelection: function(e) {
      var taskId = $(e.target).closest('select').val();

      if (!taskId) {
        return;
      }

      $resumeTaskForm.attr('action', [
        '/tasks', taskId, 'work_sessions'
      ].join('/'));

      console.warn(taskId);
      $resumeTask.prop('disabled', false);
    },

    updateTaskForm: function(projectId) {
      if (!this.project) {
        console.error('no project selected, can not update task list.');
        return false;
      }

      $newTaskForm.attr('action', [
        '/projects',
        this.project.id,
        'tasks'
      ].join('/'));
    },

    updateTaskList: function() {
      if (!this.project) {
        console.error('no project selected, can not update task list.');
        return false;
      }

      $('.project-tasks').hide();
      $('#project_' + this.project.id + '_tasks').show();
      $('[name="task_id"]:visible').trigger('change');
    },

    newTask: function(e) {
      var $modal = $('#newTaskForm').asModal();

      $modal.modal();
      $modal.on('click', 'input[type="submit"]', function() {
        $modal.find('form').submit();
      });

      return $.consume(e);
    }
  });
});