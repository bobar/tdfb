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

  $.each($('.frankiz-search'), function(i, el) {
    $(el).autocomplete({
      source: '/user/search',
      minLength: 3,
      focus: function() {
        return false;
      },
      select: function(event, ui) {
        $(el).parent().parent().parent().find('#_frankiz_id').val(ui.item.frankiz_id);
      }
    });
  });
});
