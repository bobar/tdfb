$(document).ready(function() {
  $('.cancel-transaction').click(function(event) {
    $.ajax({
      data: {
        id: event.target.parentElement.getAttribute('t-id'),
        id2: event.target.parentElement.getAttribute('t-id2'),
        date: event.target.parentElement.getAttribute('t-date'),
        price: event.target.parentElement.getAttribute('t-price'),
      },
      method: 'POST',
      dataType: 'script',
      url: '/account/cancel_transaction',
    });
  });
});
