define([
  'ext/jquery',
  'lodash',
  'backbone',
  'hbs!templates/tasks/new_modal'
], function($, _, Backbone, NewTaskModal) {
  var $resumeTaskForm, $resumeTask;

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

      $resumeTask.prop('disabled', false);
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

    getSelectedProject: function() {
      var id = this.$('[name="project_id"] :selected').val();
      var clients = ENV.USER.clients;
      var project;

      for (var i = 0; i < clients.length; ++i) {
        project = _.find(clients[i].projects, { id: id });

        if (project) {
          break;
        }
      }

      return project;
    },

    newTask: function(e) {
      var $modal = $(NewTaskModal(this.getSelectedProject())).asModal();

      $modal.modal();
      $modal.on('click', 'input[type="submit"]', function() {
        $modal.find('form').submit();
      });

      return $.consume(e);
    }
  });
});