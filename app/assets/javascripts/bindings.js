var letters = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
               'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
var numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

$(document).ready(function() {
  $('#navbar-search').autocomplete({
    source: '/account/search',
    minLength: 3,
    select: function(event, ui) {
      window.location.href = '/account/' + ui.item.value;
    }
  });

  Mousetrap.bind(letters, function() { $('#navbar-search').focus(); });
  Mousetrap.bind(numbers, function() { $('#log-form #amount').focus(); });
  Mousetrap.bind('+', function() { $('#credit-form #amount').focus(); return false; });
});
