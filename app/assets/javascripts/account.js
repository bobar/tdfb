function validateLogForm(submit) {
  var amountField = $('#log-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

function validateCreditForm(submit) {
  var amountField = $('#credit-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

function validateTransferForm(submit) {
  var amountField = $('#transfer-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  amountField.parent().toggleClass('has-error', !valid);
  var receiverField = $('#transfer-form #receiver');
  var receiver = receiverField.val();
  trigrammeExists(receiver, receiverField.parent(), submit);
  return valid && !receiverField.parent().hasClass('has-error');
}

$(document).ready(function() {
  setValidator($('#log-form'), validateLogForm);
  setValidator($('#credit-form'), validateCreditForm);
  setValidator($('#transfer-form'), validateTransferForm);
  jQuery("time.timeago").timeago();
})
