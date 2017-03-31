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
//= require bootstrap-datepicker
//= require bootstrap-filestyle
//= require bootstrap-sprockets
//= require bootstrap-table
//= require extensions/bootstrap-table-export
//= require bootstrap-table-filter-extension
//= require bootstrap-table-filter
//= require bs-table
//= require highcharts/highcharts
//= require highcharts/highcharts-more
//= require highcharts/modules/heatmap
//= require tableExport.min

function isPositiveNumber(value) {
  return new RegExp('^(\\d+(\\.\\d*)?|\\.\\d+)$').test(value);
}

function setValidator(form, handler) {
  form.change(function() { return handler(false); });
  form.on('ajax:beforeSend', function() { return handler(true); });
}

function trigrammeExists(trigramme) {
  if (typeof(trigramme) === 'undefined') return false;
  if (trigramme.length !== 3) return false;
  var request = new XMLHttpRequest();
  request.open('GET', '/account/exists/' + trigramme, false);
  request.setRequestHeader('Accept', 'application/json');
  request.send();
  if (request.status === 200) {
    return JSON.parse(request.responseText);
  }
}

function getAccount(trigramme) {
  if (typeof(trigramme) === 'undefined') return false;
  if (trigramme.length !== 3) return false;
  var request = new XMLHttpRequest();
  request.open('GET', '/account/details/' + trigramme, false);
  request.setRequestHeader('Accept', 'application/json');
  request.send();
  if (request.status === 200) {
    return JSON.parse(request.responseText);
  }
}

$(document).ajaxError(function(e, jqXHR) {
  if (jqXHR.statusText === 'canceled') {
    return;
  }
  if(jqXHR.status === 401){
    $('#unauthorized-modal').modal('show');
  } else {
    try {
      if(typeof jqXHR.responseJSON === 'undefined') {
        $('#error-modal #error-modal-text').text(JSON.parse(jqXHR.responseText)['message']);
      } else {
        $('#error-modal #error-modal-text').text(jqXHR.responseJSON['message']);
      }
    } catch(e) {
      $('#error-modal #error-modal-text').text('Something went wrong, call the SIE.');
    }
    $('#error-modal').modal('show');
  }
});

$(document).ready(function() {
  $('#trigramme-search').on('input', function() {
    var val = $('#trigramme-search').val();
    if (val.length === 3 ) {
      window.location.assign('/account/' + val);
    }
  });

  $('#account-search').autocomplete({
    autoFocus: true,
    source: '/account/search',
    minLength: 3,
    focus: function(event, ui) {
      return false;
    },
    select: function(event, ui) {
      window.location.href = '/account/' + ui.item.value;
      $('#account-search').val(ui.item.full_name);
      return false;
    }
  });

  if ($('.pagination').length) {
    $(window).scroll(function() {
      var url = $('.pagination .next_page').attr('href');
      if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 50) {
        $('.pagination').text("Please Wait...");
        return $.getScript(url);
      }
    });
    return $(window).scroll();
  }
});
