$(document).ready(function() {
  $('.cancel-transaction').click(function(event) {
    $.ajax({
      data: {
        id: event.target.getAttribute('t-id'),
        id2: event.target.getAttribute('t-id2'),
        date: event.target.getAttribute('t-date'),
        price: event.target.getAttribute('t-price'),
      },
      method: 'POST',
      dataType: 'script',
      url: '/account/cancel_transaction',
    });
  });
});
