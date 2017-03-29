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

function validateCreateForm(submit) {
  var valid = true;

  var trigrammeField = $('#account-create-form #trigramme');
  var trigramme = trigrammeField.val();
  var trigrammeValid = (trigramme.length === 3) && !trigrammeExists(trigramme, trigrammeField.parent(), submit);
  trigrammeField.parent().toggleClass('has-error', !trigrammeValid);
  valid = valid && trigrammeValid;

  var balanceField = $('#account-create-form #balance');
  var balance = balanceField.val();
  var balanceValid = isPositiveNumber(balance);
  balanceField.parent().toggleClass('has-error', !balanceValid);
  valid = valid && balanceValid;

  var nameField = $('#account-create-form #name');
  var name = nameField.val();
  var nameValid = name.length > 0;
  nameField.parent().toggleClass('has-error', !nameValid);
  valid = valid && nameValid;

  var firstNameField = $('#account-create-form #first_name');
  var firstName = firstNameField.val();
  var firstNameValid = firstName.length > 0;
  firstNameField.parent().toggleClass('has-error', !firstNameValid);
  valid = valid && firstNameValid;

  return valid;
}

$(document).ready(function() {
  setValidator($('#trigramme-form'), validateTrigrammeForm);
  setValidator($('#log-form'), validateLogForm);
  setValidator($('#credit-form'), validateCreditForm);
  setValidator($('#transfer-form'), validateTransferForm);
  setValidator($('#account-create-form'), validateCreateForm);
  jQuery("time.timeago").timeago();

  $('#frankiz-search-form #name').autocomplete({
    autoFocus: true,
    source: '/user/search',
    minLength: 3,
    focus: function(event, ui) {
      return false;
    },
    select: function(event, ui) {
      $('#account-create-form #first_name').val(ui.item.first_name);
      $('#account-create-form #name').val(ui.item.last_name);
      $('#account-create-form #birthdate').val(ui.item.birthdate);
      $('#account-create-form #promo').val(ui.item.promo);
      $('#account-create-form #email').val(ui.item.email);
      $('#account-create-form #casert').val(ui.item.casert);
      $('#account-create-form #status').val(ui.item.status);
      $('#account-create-form #_frankiz_id').val(ui.item.frankiz_id);
      return false;
    }
  });

  $('[data-toggle="tooltip"]').tooltip({
    container : 'body',
    title: function() {
      return $(this).attr('text') + ' ' + $.timeago($(this).attr('time'))
    }
  });
})
