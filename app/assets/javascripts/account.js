function validateTrigrammeForm(submit) {
  var trigrammeField = $('#trigramme-form #trigramme');
  var trigramme = trigrammeField.val();
  var exists = trigrammeExists(trigramme, trigrammeField.parent(), submit);
  trigrammeField.parent().toggleClass('has-error', exists);
  return !exists;
}

function validatePositiveNumberField(field, submit) {
  var amount = field.val();
  var valid = isPositiveNumber(amount);
  if (!submit) valid = valid || (amount === '');
  field.parent().toggleClass('has-error', !valid);
  return valid;
}

function validateLogForm(submit) {
  return validatePositiveNumberField($('#log-form #amount'), submit);
}

function validateCreditForm(submit) {
  return validatePositiveNumberField($('#credit-form #amount'), submit);
}

function validateTransferForm(submit) {
  valid = validatePositiveNumberField($('#transfer-form #amount'), submit);

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

  valid = valid && validatePositiveNumberField($('#account-create-form #balance'), true);

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
  jQuery('time.timeago').timeago();

  $('#frankiz-search-form #name').autocomplete({
    autoFocus: true,
    source: '/user/search',
    minLength: 3,
    focus: function() {
      return false;
    },
    select: function(event, ui) {
      $('#account-create-form #first_name').val(ui.item.first_name);
      $('#account-create-form #name').val(ui.item.last_name);
      $('#account-create-form #birthdate').datepicker('update', new Date(ui.item.birthdate));
      $('#account-create-form #promo').val(ui.item.promo);
      $('#account-create-form #email').val(ui.item.email);
      $('#account-create-form #casert').val(ui.item.casert);
      $('#account-create-form #_status').val(ui.item.status);
      $('#account-create-form #_frankiz_id').val(ui.item.frankiz_id);
      $('#new-account-image').attr('src', 'https://www.frankiz.net/' + ui.item.picture);
      $('#account-create-form #trigramme').focus();
      return false;
    }
  });

  $('#frankiz-search-form #name').focus();

  $('[data-toggle="tooltip"]').tooltip({
    container : 'body',
    title: function() {
      return $(this).attr('text') + ' ' + $.timeago($(this).attr('time'));
    }
  });

  var ranges = ['id', 'frankiz_id', 'birthdate', 'promo', 'budget', 'turnover'];
  var filters = $('#table-filter th').map(function(i, th) {
    var field = $(th).attr('data-field');
    if (field === 'readable_status') {
      return {
        field: field,
        label: th.textContent,
        type: 'select',
        values: [
          { id: 'X platal', label: 'X platal' },
          { id: 'X ancien', label: 'X ancien' },
          { id: 'Binet', label: 'Binet' },
          { id: 'Personnel', label: 'Personnel' },
          { id: 'Etudiant non x', label: 'Etudiant non X' },
          { id: 'Autre', label: 'Autre' }
        ]
      };
    }
    return {
      field: field,
      label: th.textContent,
      type: ranges.includes(field) ? 'range' : 'search'
    };
  });
  $('#filter-bar').bootstrapTableFilter({
    connectTo: '#table-filter',
    filters: filters,
    // onSubmit: function() {
    //   var data = $('#filter-bar').bootstrapTableFilter('getData');
    // }
  });
  var year = new Date().getFullYear() - 2;
  $('#filter-bar').bootstrapTableFilter('setupFilter', 'promo', { gte: year });
  $('#filter-bar').bootstrapTableFilter('setupFilter', 'casert');
  $('#filter-bar').bootstrapTableFilter('setupFilter', 'readable_status');
  $('#filter-bar').bootstrapTableFilter('setupFilter', 'budget', { lte: -1 });

});

$(document).on('ready page:load', function () {
  $('#filter-bar').submit();
  $('#filter-bar').bootstrapTableFilter('toggleRefreshButton', false);
});

$(document).on('keyup', '#_clope_id', function(e) {
  if(e.keyCode == 39) {
    $('#quantity').focus();
  }
});
