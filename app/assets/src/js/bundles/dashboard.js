define([
  'jquery',
  'views/dashboard/active',
  'views/dashboard/timer'
], function($, ActiveView, TimerView) {

  var activeView = new ActiveView();
  var timerView = new TimerView();

  $(function() {
    activeView.render();

    if (ENV.WORK_SESSION) {
      timerView.render(ENV.WORK_SESSION.started_at);
      timerView.$el.appendTo($('#wsTimer'));
    }
  });
});