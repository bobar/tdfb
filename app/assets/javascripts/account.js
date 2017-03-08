function validateLogForm() {
  var amountField = $('#log-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

function validateCreditForm() {
  var amountField = $('#credit-form #amount');
  var amount = amountField.val();
  var valid = isPositiveNumber(amount);
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

$(document).ready(function() {
  setValidator($('#log-form'), validateLogForm);
  setValidator($('#credit-form'), validateCreditForm);
})
