function validateTrigrammeForm(submit) {
  var trigrammeField = $('#trigramme-form #trigramme');
  var trigramme = trigrammeField.val();
  var exists = trigrammeExists(trigramme, trigrammeField.parent(), submit);
  trigrammeField.parent().toggleClass('has-error', exists);
  return !exists;
}

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
  var exists = trigrammeExists(receiver, receiverField.parent(), submit);
  receiverField.parent().toggleClass('has-error', !exists);
  return valid && exists;
}

$(document).ready(function() {
  setValidator($('#trigramme-form'), validateTrigrammeForm);
  setValidator($('#log-form'), validateLogForm);
  setValidator($('#credit-form'), validateCreditForm);
  setValidator($('#transfer-form'), validateTransferForm);
  jQuery("time.timeago").timeago();
})
