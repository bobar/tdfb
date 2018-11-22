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
//= require turbolinks
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
//= require mousetrap.min
//= require timeago

/* eslint-disable no-unused-vars */

function isPositiveNumber(value) {
  return new RegExp('^(\\d+(\\.\\d*)?|\\.\\d+)$').test(value);
}

function setValidator(form, handler) {
  form.change(function() { return handler(false); });
  form.on('ajax:beforeSend', function() { return handler(true); });
}

function accountRequest(endpoint, trigramme) {
  if (typeof(trigramme) === 'undefined') return false;
  if (trigramme.length !== 3) return false;
  var request = new XMLHttpRequest();
  request.open('GET', endpoint + trigramme, false);
  request.setRequestHeader('Accept', 'application/json');
  request.send();
  if (request.status === 200) {
    return JSON.parse(request.responseText);
  }
}

function trigrammeExists(trigramme) {
  return accountRequest('/account/exists/', trigramme);
}

function getAccount(trigramme) {
  return accountRequest('/account/details/', trigramme);
}

$(document).ajaxError(function(e, jqXHR) {
  if (jqXHR.statusText === 'canceled' || jqXHR.status === 200) {
    return;
  }
  if (jqXHR.status === 401) {
    if (jqXHR.getResponseHeader('Auth_reason') !== null) {
      $('#unauthorized-modal .modal-body').html(jqXHR.getResponseHeader('Auth_reason'));
    } else {
      $('#unauthorized-modal .modal-body').html('L\'authentification a échouée.');
    }
    $('#unauthorized-modal').modal('show');
  } else if (jqXHR.status === 499) {
    // Invalid authenticity token, let's prompt to try again and refresh the page
    $('#error-modal #error-modal-text').html(
      'Oups, <a href="#" onclick="Turbolinks.visit(window.location);">rafraichissez la page</a> et réessayez.'
    );
    $('#error-modal').modal('show');
  } else {
    try {
      if(typeof jqXHR.responseJSON === 'undefined') {
        $('#error-modal #error-modal-text').html(JSON.parse(jqXHR.responseText)['message']);
      } else {
        $('#error-modal #error-modal-text').html(jqXHR.responseJSON['message']);
      }
    } catch(e) {
      $('#error-modal #error-modal-text').text('Something went wrong, call the SIE.');
    }
    $('#error-modal').modal('show');
  }
});

$(document).on('ready turbolinks:load', function() {
  try {
    Raven.config('https://27660d4e6a794beaacb08a6e987ef257@sentry.io/175369').install();
  } catch (e) {
    /* eslint-disable */
    console.warn('Failed to initialize Raven: ', e);
    /* eslint-enable */
  }

  $('#trigramme-search').on('input', function() {
    var val = $('#trigramme-search').val();
    if (val.length === 3) {
      Turbolinks.visit('/account/' + val);
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
      Turbolinks.visit('/account/' + ui.item.value);
      $('#account-search').val(ui.item.full_name);
      return false;
    }
  });

  if ($('.pagination').length) {
    $(window).scroll(function() {
      var url = $('.pagination .next_page').attr('href');
      if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 50) {
        $('.pagination').text($('.wait').attr('data-text'));
        return $.getScript(url);
      }
    });
    return $(window).scroll();
  }
});
