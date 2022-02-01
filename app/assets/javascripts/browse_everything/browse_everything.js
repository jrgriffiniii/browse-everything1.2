//= require jquery3
//= require bootstrap-sprockets

(function($) {
  $.fn.browseEverything = {};

  $.fn.browseEverything.reset = function() {
    $(this).browseEverything.resetElement = $(this);
  }

  $.fn.browseEverything.submitDefaultCallback = function( event ) {
    event.preventDefault();

    $(this).off('submit', $(this).browseEverything.submitDefaultCallback);
    $(this).submit();
  }

  $.fn.browseEverything.submit = function() {
    $(this).browseEverything.submitElement = $(this);

    $(this).browseEverything.formElement.on("submit", $(this).browseEverything.submitDefaultCallback);
  }

  $.fn.browseEverything.node = function() {
    $(this).children('input').on("change", function( event ) {
      const values = $(this).browseEverything.formElement.serializeArray();

      if ( values.length > 0 ) {
        $(this).browseEverything.submitElement.prop('disabled', false);
        $(this).browseEverything.resetElement.prop('disabled', false);
      } else {
        $(this).browseEverything.submitElement.prop('disabled', true);
        $(this).browseEverything.resetElement.prop('disabled', true);
      }
    });
  }

  $.fn.browseEverything.folder = function() {
    $(this).children('label').on( "click", function( event ) {
      if( $(this).find('.glyphicon').hasClass('glyphicon-folder-close') ) {
        $(this)
          .find('.glyphicon')
          .removeClass('glyphicon-folder-close')
          .addClass('glyphicon-folder-open')
          .parent()
          .siblings('.folder__children')
          .addClass('expanded')
          .siblings('input')
          .prop('disabled', true)
          .prop('checked', false);
      } else if( $(this).find('.glyphicon').hasClass('glyphicon-folder-open') ) {
        $(this)
          .find('.glyphicon')
          .removeClass('glyphicon-folder-open')
          .addClass('glyphicon-folder-close')
          .parent()
          .siblings('.folder__children')
          .removeClass('expanded')
          .siblings('input')
          .prop('disabled', false)
          .prop('checked', false);
      }
    } );
  };

  $.fn.browseEverything.form = function() {
    $(this).browseEverything.formElement = $(this);

    $(this).find('.folder').each( function( event ) {
      $(this).browseEverything.folder.call(this);
    } );

    $(this).find('.node').each( function( event ) {
      $(this).browseEverything.node.call(this);
    } );

    $(this).find('.submit').each( function( event ) {
      $(this).browseEverything.submit.call(this);
    } );

    $(this).find('.reset').each( function( event ) {
      $(this).browseEverything.reset.call(this);
    } );
  };

}( jQuery ));

$(document).ready(function() {
  $('form.browse-everything').each(function( event ) {
    $(this).browseEverything.form.call(this);
  });
});
