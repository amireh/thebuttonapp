define([
  'ext/jquery',
  'backbone',
  'hbs!templates/tasks/edit_modal',
  'toastr'
], function($, Backbone, Template, toastr) {
  return Backbone.View.extend({
    events: {
      'click [data-action="editTask"]': 'loadAndShow'
    },

    $modal: null,

    getTask: function() {
      return ENV.TASK;
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
      toastr.info('Loading...');

      $.ajaxJSON({
        type: 'GET',
        url: task.media.url,
        success: function(task) {
          toastr.clear();
          callback.apply(thisArg, [ task ]);
        }
      });
    },

    createModal: function(task) {
      this.$modal = $(Template(task)).asModal();
      this.$modal.on('click', '[data-action="saveTask"]', _.bind(this.update, this));
      this.$modal.on('submit', 'form', $.consume);

      this.$modal.find('form').formParams(task);

      return this.$modal;
    },

    showModal: function() {
      this.$modal.modal('show');
    },

    update: function(e) {
      var data = this.$modal.find('form').serializeObject();
      var $savingToast = toastr.info('Saving...');

      $.ajaxJSON({
        type: "PATCH",
        url: this.$modal.find('form').attr('action'),
        data: JSON.stringify(data),
        success: function() {
          toastr.clear($savingToast);
          toastr.success('Task has been updated.');
        },
        error: function() {
          toastr.error('Unable to update task, please try again later.');
          console.error(arguments);
        }
      });
    }
  });
});