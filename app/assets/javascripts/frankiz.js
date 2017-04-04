$(document).ready(function() {
  $('time.timeago').timeago();

  $('.refresh-promo').click(function(event) {
    $.ajax({
      data: {
        password: $('#frankiz-form #password').val(),
        promo: event.target.getAttribute('promo'),
        username: $('#frankiz-form #username').val(),
      },
      method: 'POST',
      dataType: 'script',
      url: '/frankiz/refresh_promo',
    });
  });
});
