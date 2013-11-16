define([
  'ext/jquery',
  'backbone',
  'hbs!templates/work_sessions/edit',
  'toastr'
], function($, Backbone, Template, toastr) {
  return Backbone.View.extend({
    events: {
      'click .edit-work-session': 'loadAndShow'
    },

    $modal: null,

    getTask: function() {
      return ENV.TASK;
    },

    getWorkSession: function(id) {
      return _.find(this.getTask().work_sessions, { id: id });
    },

    render: function() {
      this.$el = $('#content');
      this.delegateEvents();
    },

    loadAndShow: function(e) {
      $.consume(e);

      var $item = $(e.target).closest('[data-workSession]');
      var id = $item.attr('data-workSession');
      var ws = this.getWorkSession(id);

      if (!ws) {
        toastr.error('Hmm, it looks like there isn\'t such a work session.');
        return false;
      }

      this.loadWorkSession(ws, function(ws) {
        this.createModal(ws);
        this.showModal();
      }, this);
    },

    loadWorkSession: function(ws, callback, thisArg) {
      toastr.info('Loading...');

      $.ajaxJSON({
        type: 'GET',
        url: ws.media.url,
        success: function(ws) {
          callback.apply(thisArg, [ ws ]);
        }
      });
    },

    createModal: function(ws) {
      this.$modal = $(Template(ws)).asModal();
      this.$modal.on('click', '[data-action="saveWorkSession"]', _.bind(this.update, this));
      this.$modal.on('submit', 'form', $.consume);

      return this.$modal;
    },

    showModal: function() {
      this.$modal.modal('show');
    },

    update: function(e) {
      var data = this.$modal.find('form').serializeObject();
      data.duration = parseInt(data.duration, 10) * 60;

      $.ajaxJSON({
        type: "PATCH",
        url: this.$modal.find('form').attr('action'),
        data: JSON.stringify(data),
        success: function() {
          toastr.success('Work session has been updated.');
        },
        error: function() {
          toastr.error('Unable to update work session, please try again later.');
          console.error(arguments);
        }
      });
    }
  });
});