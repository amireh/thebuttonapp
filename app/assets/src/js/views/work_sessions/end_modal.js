define([
  'ext/jquery',
  'backbone',
  'hbs!templates/work_sessions/end_modal',
  'toastr'
], function($, Backbone, Template, toastr) {
  return Backbone.View.extend({
    events: {
      'click [data-action="endWorkSession"]': 'loadAndShow'
    },

    $modal: null,

    getTask: function() {
      return ENV.TASK;
    },

    getWorkSession: function() {
      return ENV.WORK_SESSION;
    },

    render: function() {
      this.$el = $('#content');
      this.delegateEvents();
    },

    loadAndShow: function(e) {
      $.consume(e);

      this.loadTask(this.getTask(), function(task) {
        this.createModal(task);
        this.showModal();
      }, this);
    },

    loadTask: function(task, callback, thisArg) {
      callback.apply(thisArg, [ this.getTask() ]);
      // toastr.info('Loading...');

      // $.ajaxJSON({
      //   type: 'GET',
      //   url: task.media.url,
      //   success: function(task) {
      //     toastr.clear();
      //     callback.apply(thisArg, [ task ]);
      //   }
      // });
    },

    createModal: function(task) {
      this.$modal = $(Template(task)).asModal();
      this.$modal.on('click', '[data-action="saveWorkSession"]', _.bind(this.update, this));
      this.$modal.on('submit', 'form', $.consume);

      this.$modal.find('form').formParams(_.merge({}, task, {
        task_status: task.status
      }));

      return this.$modal;
    },

    showModal: function() {
      this.$modal.modal('show');
    },

    update: function(e) {
      var data = this.$modal.find('form').serializeObject();
      var $savingToast = toastr.info('Saving...');

      $.ajaxJSON({
        type: 'PATCH',
        url: this.getWorkSession().media.url,
        data: JSON.stringify(data),
        success: function() {
          toastr.clear($savingToast);
          toastr.success('Work session has been ended, please wait while we' +
            ' take you back to the dashboard.');

          window.location.href = '/';
        },
        error: function() {
          toastr.error('Unable to end the current work session, please try again later.');
          console.error(arguments);
        }
      });
    }
  });
});