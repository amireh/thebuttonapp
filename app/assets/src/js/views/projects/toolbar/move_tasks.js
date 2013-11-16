define([
  'ext/jquery',
  'backbone',
  'hbs!templates/projects/toolbar/move_tasks',
  'toastr'
], function($, Backbone, Template, toastr) {
  return Backbone.View.extend({
    events: {
      'click [data-action="showTaskMovementDialog"]': 'showModal'
    },

    user: ENV.USER,

    $modal: null,
    $progress: null,

    getProjects: function(user) {
      var clients = user.clients;
      var projects = _.map(clients, function(client) {
        return client.projects;
      });

      return _.flatten(projects);
    },

    getTasks: function(user) {
      var projects = this.projects || this.getProjects(user);
      var tasks = _.map(projects, function(project) {
        return project.tasks;
      });

      return _.flatten(tasks);
    },

    render: function() {
      this.projects = this.getProjects(this.user);
      this.tasks = this.getTasks();

      this.$el = $('#content');
      this.$modal = $(Template({
        projects: this.projects
      })).asModal();

      this.$modal.on('click', '[data-action="moveTasks"]', _.bind(this.moveTasks, this));
      this.$progress = this.$modal.find('.progress').hide();
      this.$tick = this.$modal.find('.progress-bar').hide();

      this.delegateEvents();
    },

    showModal: function() {
      this.$modal.modal('show');
      this.$progress.hide();

      this._progress = 0;
      this._progressSteps = 0;
      this.updateProgressBar();
    },

    moveTasks: function() {
      var tasks = this.getSelectedTasks();
      var projectId = this.$modal.find('[name="project_id"] :selected').val();
      var project = _.find(this.projects, { id: projectId });
      var that = this;

      console.debug('moving', tasks.length, 'tasks to project', project, projectId);

      if (!project) {
        console.error('unable to find project!');
        return;
      }

      this.prepareProgressBar(tasks.length);

      this._tasksToMove = tasks;
      this.moveTask(tasks.pop(), project, _.bind(this.moveNextTask, this));
    },

    moveTask: function(task, project, callback) {
      if (this.$toast) {
        toastr.clear(this.$toast);
        this.$toast = null;
      }

      var that = this;
      this.$toast = toastr.info('Moving task "' + task.name + '"...');

      if (project.id == task.project_id) {
        // toastr.clear(this.$toast);
        this.$toast = toastr.warning('That task already belongs to that project!')
        return callback(project);
      }

      $.ajaxJSON({
        type: "PATCH",
        url: task.media.url,
        data: JSON.stringify({
          new_project_id: project.id
        }),
        success: function() {
          that.tickProgressBar();
          toastr.clear(that.$toast);
          that.$toast = toastr.success('Task moved!');
          callback(project);
        },
        error: function(data) {
          toastr.error('Unable to move task!');
        }
      });
    },

    moveNextTask: function(project) {
      var task = this._tasksToMove.pop();

      if (task) {
        this.moveTask(task, project, _.bind(this.moveNextTask, this));
      }
    },

    prepareProgressBar: function(nrSteps) {
      this._progressSteps = nrSteps;
      this._progress = 0;

      this.$progress.show();
      this.$tick.show();
      this.updateProgressBar();
    },

    tickProgressBar: function() {
      ++this._progress;
      this.updateProgressBar();
    },

    updateProgressBar: function() {
      this.$tick.css({ width: (this._progress / this._progressSteps * 100) + '%' });
    },

    getSelectedTasks: function() {
      var $tasks = $('[name*="tasks"][type="checkbox"]:checked');
      var tasks = this.tasks;

      var taskIds = $tasks.map(function() {
        return $(this).val();
      });

      return _.map(taskIds, function(taskId) {
        return _.find(tasks, { id: taskId });
      });
    }
  });
});