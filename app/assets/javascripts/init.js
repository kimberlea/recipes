jconfirm.defaults = {
  columnClass: 'col-lg-4 col-lg-offset-4 col-sm-8 col-sm-offset-2 col-xs-10 col-xs-offset-1'
};

function updateResponsiveSettings() {
  var width = $(window).width();
  var $body = $('body');
  $body.removeClass("layout-mobile layout-mobile-phone layout-mobile-tablet layout-desktop");
  if (width < 768) {
    window.app_display_layout = "mobile";
    window.app_display_sublayout = "phone";
    $body.addClass("layout-mobile layout-mobile-phone");
  } else if (width < 992) {
    window.app_display_layout = "mobile";
    window.app_display_sublayout = "tablet";
    $body.addClass("layout-mobile layout-mobile-tablet");
  } else {
    window.app_display_layout = "desktop";
    $body.addClass("layout-desktop");
  }
}

$(document).ready(function() {
  updateResponsiveSettings();
  $(window).resize(updateResponsiveSettings);
});
