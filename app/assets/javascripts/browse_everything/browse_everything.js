//= require jquery3
//= require bootstrap-sprockets

(function( $ ) {

$.fn.toggleFolder = function() {

  if( $(this).find('.glyphicon').hasClass('glyphicon-folder-close') ) {
    $(this)
      .find('.glyphicon')
      .removeClass('glyphicon-folder-close')
      .addClass('glyphicon-folder-open')
      .parent()
      .siblings('.folder__children')
      .addClass('expanded');
  } else {
    $(this)
      .find('.glyphicon')
      .removeClass('glyphicon-folder-open')
      .addClass('glyphicon-folder-close')
      .parent()
      .siblings('.folder__children')
      .removeClass('expanded');
  }
};

}( jQuery ));

$( document ).ready(function() {
  $('.folder label').on( "click", function( event ) {

    $(this).toggleFolder();
    //$(this).children('.file').toggleClass('expanded');
  } );
});
