function validateLogForm(submit=false) {
  var amountField = $('#log-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

function validateCreditForm(submit=false) {
  var amountField = $('#credit-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

$(document).ready(function() {
  setValidator($('#log-form'), validateLogForm);
  setValidator($('#credit-form'), validateCreditForm);
  jQuery("time.timeago").timeago();
})
