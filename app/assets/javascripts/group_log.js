function validateGroupLogForm(submit) {
  var amountField = $('#group-log-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  amountField.parent().toggleClass('has-error', !valid);
  var trigrammeRows = $('#group-log-form .trigramme-row');
  trigrammeRows.each(function(idx, el) {
    var trigrammeField = $(el).find('input');
    var trigramme = trigrammeField.val();
    var account = getAccount(trigramme);
    var ok = account || typeof(trigramme) === 'undefined' || trigramme === '';
    trigrammeField.parent().toggleClass('has-error', !ok);
    valid = valid && !!ok;
    if (account) {
      $(el).find('.account-label').html(account.display_text);
    } else {
      $(el).find('.account-label').html('');
    }
  });
  return valid;
}

function addTrigrammeRow() {
  var last_row = $('.trigramme-row').last();
  var new_row = last_row.clone();
  new_row.find('input').val(null);
  new_row.find('.account-label').html('');
  last_row.parent().append(new_row);
  last_row.find('input').off('focus');
  new_row.find('input').focus(addTrigrammeRow);
}

$(document).ready(function() {
  setValidator($('#group-log-form'), validateGroupLogForm);
  $('.trigramme-row input').focus(addTrigrammeRow);
});
