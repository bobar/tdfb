function validateLogForm() {
  var amountField = $('#log-form #amount');
  var amount = amountField.val();
  var valid = new RegExp('^\\d+(\\.\\d*)?$').test(amount);
  amountField.parent().toggleClass('has-error', !valid);
  return valid;
}

$(document).ready(function() {
  $('#log-form').change(validateLogForm);
  $('#log-form').submit(function(e) {
    if (!validateLogForm()) {
      e.preventDefault();
    }
  });
})
