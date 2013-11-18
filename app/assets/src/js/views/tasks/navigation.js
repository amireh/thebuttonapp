define([ 'ext/jquery', 'backbone' ], function($, Backbone) {
  return Backbone.View.extend({
    render: function() {
      var $window = $(window)
      var $body   = $(document.body)

      var navHeight = $('.navbar').outerHeight(true) + 10

      $body.scrollspy({
        target: '.bs-sidebar',
        offset: navHeight
      });

      $window.on('load', function () {
        $body.scrollspy('refresh')
      });

      var $sideBar = $('.bs-sidebar')

      $sideBar.affix({
        offset: {
          top: 60
        , bottom: function () {
            return (this.bottom = $('.bs-footer').outerHeight(true))
          }
        }
      })
    }
  });
});