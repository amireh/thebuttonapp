define([
  'ext/jquery',
  'lodash',
  'backbone',
  'moment',
  'views/dashboard/timer'
], function($, _, Backbone, moment, TimerView) {
  var root = this;
  var ENV = root.ENV;
  var $newTaskForm;
  var $resumeTaskForm;
  var $resumeTask;

  return Backbone.View.extend({
    events: {
      'click [data-action="backtrack"]': 'showBacktrackingModal'
    },

    ui: {
      backtrackingModal: null
    },

    render: function() {
      this.setElement('#content');
      this.delegateEvents();

      var $modal = this.ui.backtrackingModal = $('#backtrackingForm').asModal();

      $modal.modal({
        show: false
      });

      $modal.on('click', '[data-action="save"]', _.bind(this.backtrack, this));
      $modal.on('submit', 'form', _.bind(this.backtrack, this));
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
});