define([ 'ext/jquery', 'lodash', 'backbone', 'moment' ], function($, _, Backbone, moment) {
  var root = this;
  var ENV = root.ENV;
  var $newTaskForm;
  var $resumeTaskForm;
  var $resumeTask;

  return Backbone.View.extend({
    events: {
      'change [name="project_id"]': 'onProjectSelection',
      'change [name="task_id"]': 'onTaskSelection',
      'click [data-action="newTask"]': 'newTask',
      'click [data-action="backtrack"]': 'showBacktrackingModal'
    },

    ui: {
      backtrackingModal: null
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

      if ($('#backtrackingForm').length) {
        var $modal = this.ui.backtrackingModal = $('#backtrackingForm').asModal();

        $modal.modal({
          show: false
        });

        $modal.on('click', '[data-action="save"]', _.bind(this.backtrack, this));
        $modal.on('submit', 'form', _.bind(this.backtrack, this));
      }

      this._legacyCode();
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
    },

    showBacktrackingModal: function() {
      var that = this;
      this.ui.backtrackingModal.modal('show');
      that.ui.backtrackingModal.find('[autofocus]').focus();
    },

    backtrack: function(e) {
      var $modal = this.ui.backtrackingModal;
      var workSession = ENV.WORK_SESSION;

      var data = $modal.find('form').serializeObject();
      data.amount = parseInt(data.amount, 10) *-1;
      var newTimestamp = moment.utc(workSession.started_at).add(data.amount, 'minutes');

      $.ajaxJSON({
        type: 'PATCH',
        url: workSession.media.url,
        data: JSON.stringify({
          started_at: newTimestamp
        }),
        success: function() {
          location.reload();
        }
      });

      return $.consume(e);
    },

    _legacyCode: function() {
      var submit_form = window.submit_form = function() {
        $("body").append($("#end_session").detach());
        $("#end_session").submit();
      };

      $('#task_editor').jqm({
        overlay: 88,
        ajax: $("a#edit_task").attr("href"),
        trigger: 'a#edit_task',
        modal: false,
        onLoad: function() {
          $(this).parent().show();
          $(this).find('[name="status"]').closest('fieldset').remove();
        }
      });

      $('#ws_editor').jqm({
        overlay: 88,
        ajax: '@href',
        trigger: 'a.edit-work-session',
        onLoad: function() {
          $(this).parent().show();
        }
      });
    }
  });
});