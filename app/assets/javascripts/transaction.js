function buttonCancelTransation() {
  $('.cancel-transaction').click(function(event) {
    $.ajax({
      data: {
        transaction_id: event.target.parentElement.getAttribute('transaction-id'),
      },
      method: 'POST',
      dataType: 'script',
      url: '/account/cancel_transaction',
    });
  });
}

$(document).ready(function() {
  buttonCancelTransation();
});
