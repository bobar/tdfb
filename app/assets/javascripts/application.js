// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery-ui/widgets/autocomplete
//= require jquery_ujs
//= require_tree .
//= require bootstrap-sprockets

function isPositiveNumber(value) {
  return new RegExp('^\\d+(\\.\\d*)?$').test(value);
}

function setValidator(form, handler) {
  form.change(function() { return handler(false); });
  form.on('ajax:beforeSend', function() { return handler(true); });
}

$(document).ajaxError(function(e, jqXHR) {
  if (jqXHR.statusText === 'canceled') {
    return;
  }
  if(jqXHR.status === 401){
    $('#unauthorized-modal').modal('show');
  } else {
    $('#error-modal').modal('show');
  }
});
