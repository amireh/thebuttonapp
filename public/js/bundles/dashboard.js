(function(root, $, ENV) {
  var $newTaskForm;
  var $resumeTaskForm;
  var $resumeTask;

  var TimerView = Backbone.View.extend({
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

  var DashboardView = Backbone.View.extend({
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
    }
  });

  var dashboardView = root.DashboardView = new DashboardView();
  var timerView = root.TimerView = new TimerView();

  $(function() {
    dashboardView.render();

    if (ENV.WORK_SESSION) {
      timerView.render(ENV.WORK_SESSION.started_at);
      timerView.$el.appendTo($('#wsTimer'));
    }
  });
})(this, this.$, this.ENV);